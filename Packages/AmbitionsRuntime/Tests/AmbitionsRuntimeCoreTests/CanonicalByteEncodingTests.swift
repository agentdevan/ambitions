import Foundation
import XCTest
import AmbitionsRuntimeCore

final class CanonicalByteEncodingTests: XCTestCase {
    func testCanonicalEncodingUsesStableKeyDateDataAndSlashConfiguration() throws {
        struct Payload: Encodable {
            let name: String
            let date: Date
            let bytes: Data
        }

        let encoded = try CanonicalByteEncoder().encode(
            Payload(
                name: "alpha/beta",
                date: Date(timeIntervalSince1970: 1.25),
                bytes: Data([0, 1, 2])
            )
        )

        XCTAssertEqual(
            String(decoding: encoded, as: UTF8.self),
            #"{"bytes":"AAEC","date":1250,"name":"alpha/beta"}"#
        )
    }

    func testSHA256DigestMatchesPublishedVectorAndRoundTripsCodable() throws {
        let digest = SHA256Digest.digest(Data("abc".utf8))

        XCTAssertEqual(
            digest.hexadecimal,
            "ba7816bf8f01cfea414140de5dae2223"
                + "b00361a396177a9cb410ff61f20015ad"
        )
        XCTAssertEqual(digest.bytes.count, SHA256Digest.byteCount)
        XCTAssertEqual(try SHA256Digest(bytes: digest.bytes), digest)
        XCTAssertEqual(try SHA256Digest(hexadecimal: digest.hexadecimal), digest)

        let encoded = try JSONEncoder().encode(digest)
        let decoded = try JSONDecoder().decode(SHA256Digest.self, from: encoded)
        XCTAssertEqual(decoded, digest)
    }

    func testDigestOfCanonicalValueIsIndependentOfDictionaryInsertionOrder() throws {
        let first = ["bravo": 2, "alpha": 1]
        let second = ["alpha": 1, "bravo": 2]

        XCTAssertEqual(
            try SHA256Digest.digest(canonicalEncoding: first),
            try SHA256Digest.digest(canonicalEncoding: second)
        )
    }

    func testCoreErrorsDoNotExposeUnderlyingPrivateValues() throws {
        struct FailingValue: Encodable {
            enum Failure: Error {
                case privateValue(String)
            }

            func encode(to encoder: Encoder) throws {
                throw Failure.privateValue("private-content-marker")
            }
        }

        XCTAssertThrowsError(try CanonicalByteEncoder().encode(FailingValue())) {
            XCTAssertEqual($0 as? CanonicalEncodingError, .encodingFailed)
            XCTAssertFalse(String(describing: $0).contains("private-content-marker"))
        }

        XCTAssertThrowsError(try SHA256Digest(hexadecimal: "private-digest-marker")) {
            XCTAssertEqual($0 as? SHA256DigestError, .invalidDigest)
            XCTAssertFalse(String(describing: $0).contains("private-digest-marker"))
        }
    }
}
