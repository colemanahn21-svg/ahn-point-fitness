import XCTest
@testable import AhnPointFitness

/// Answers WHOOP's token endpoint and counts how often it was hit.
final class TokenEndpointStub: URLProtocol {
    nonisolated(unsafe) static var hits = 0
    nonisolated(unsafe) static var status = 200
    nonisolated(unsafe) static var body = #"{"access_token":"fresh","refresh_token":"rotated","expires_in":3600}"#

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        Self.hits += 1
        // Slow enough that concurrent callers overlap, like a real network.
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.3) {
            let response = HTTPURLResponse(url: self.request.url!, statusCode: Self.status,
                                           httpVersion: nil, headerFields: nil)!
            self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            self.client?.urlProtocol(self, didLoad: Data(Self.body.utf8))
            self.client?.urlProtocolDidFinishLoading(self)
        }
    }

    override func stopLoading() {}
}

@MainActor
final class WhoopAuthRefreshTests: XCTestCase {
    private var auth: WhoopAuth!

    override func setUp() async throws {
        TokenEndpointStub.hits = 0
        TokenEndpointStub.status = 200
        TokenEndpointStub.body = #"{"access_token":"fresh","refresh_token":"rotated","expires_in":3600}"#
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [TokenEndpointStub.self]
        auth = WhoopAuth(session: URLSession(configuration: config))
        // Expired access token, so every caller needs a refresh.
        try auth.storeTokensForTesting(access: "stale", refresh: "original",
                                       expiresAt: Date().addingTimeInterval(-60))
    }

    override func tearDown() async throws {
        auth.disconnect()
    }

    /// The Today card fetches three endpoints at once. WHOOP rotates the
    /// refresh token per use and revokes the chain on reuse, so three
    /// parallel refreshes kill the connection. Only one may go out.
    func testParallelCallersShareOneRefresh() async throws {
        async let a = auth.getValidAccessToken()
        async let b = auth.getValidAccessToken()
        async let c = auth.getValidAccessToken()
        let tokens = try await [a, b, c]

        XCTAssertEqual(TokenEndpointStub.hits, 1, "each parallel caller refreshed on its own")
        XCTAssertEqual(tokens, ["fresh", "fresh", "fresh"])
        XCTAssertTrue(auth.isConnected)
    }

    /// WHOOP's real answer to a dead refresh token (captured from the phone).
    func testDeadTokenDisconnectsSoTheCardAsksToReconnect() async {
        TokenEndpointStub.status = 400
        TokenEndpointStub.body = #"{"error":"invalid_request","error_description":"The request is missing a required parameter","status_code":400}"#

        do {
            _ = try await auth.getValidAccessToken()
            XCTFail("a rejected refresh must throw")
        } catch {}
        XCTAssertFalse(auth.isConnected, "stayed 'connected' with a dead token, so data goes stale silently")
    }

    func testOnlyTokenRejectionsCountAsDead() {
        XCTAssertTrue(WhoopAuth.isDeadRefreshToken(status: 400, body: #"{"error":"invalid_request"}"#))
        XCTAssertTrue(WhoopAuth.isDeadRefreshToken(status: 400, body: #"{"error":"invalid_grant"}"#))
        XCTAssertFalse(WhoopAuth.isDeadRefreshToken(status: 401, body: #"{"error":"invalid_client"}"#),
                       "a wrong client secret is a config bug, not a dead token")
        XCTAssertFalse(WhoopAuth.isDeadRefreshToken(status: 503, body: "invalid_request"),
                       "server errors are transient")
    }
}
