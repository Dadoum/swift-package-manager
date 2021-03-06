/*
 This source file is part of the Swift.org open source project

 Copyright (c) 2020 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception

 See http://swift.org/LICENSE.txt for license information
 See http://swift.org/CONTRIBUTORS.txt for Swift project authors
 */

import SPMTestSupport
import XCTest

@testable import PackageCollections
@testable import PackageModel

final class PackageCollectionsModelTests: XCTestCase {
    func testLatestVersions() {
        let targets = [PackageCollectionsModel.Target(name: "Foo", moduleName: "Foo")]
        let products = [PackageCollectionsModel.Product(name: "Foo", type: .library(.automatic), targets: targets)]
        let toolsVersion = ToolsVersion(string: "5.2")!
        let versions: [PackageCollectionsModel.Package.Version] = [
            .init(
                version: .init(stringLiteral: "1.2.0"), packageName: "FooBar", targets: targets, products: products,
                toolsVersion: toolsVersion, minimumPlatformVersions: nil, verifiedCompatibility: nil, license: nil
            ),
            .init(
                version: .init(stringLiteral: "2.0.1"), packageName: "FooBar", targets: targets, products: products,
                toolsVersion: toolsVersion, minimumPlatformVersions: nil, verifiedCompatibility: nil, license: nil
            ),
            .init(
                version: .init(stringLiteral: "2.1.0-beta.3"), packageName: "FooBar", targets: targets, products: products,
                toolsVersion: toolsVersion, minimumPlatformVersions: nil, verifiedCompatibility: nil, license: nil
            ),
            .init(
                version: .init(stringLiteral: "2.1.0"), packageName: "FooBar", targets: targets, products: products,
                toolsVersion: toolsVersion, minimumPlatformVersions: nil, verifiedCompatibility: nil, license: nil
            ),
            .init(
                version: .init(stringLiteral: "3.0.0-beta.1"), packageName: "FooBar", targets: targets, products: products,
                toolsVersion: toolsVersion, minimumPlatformVersions: nil, verifiedCompatibility: nil, license: nil
            ),
        ]

        XCTAssertEqual("2.1.0", versions.latestRelease?.version.description)
        XCTAssertEqual("3.0.0-beta.1", versions.latestPrerelease?.version.description)
    }

    func testNoLatestReleaseVersion() {
        let targets = [PackageCollectionsModel.Target(name: "Foo", moduleName: "Foo")]
        let products = [PackageCollectionsModel.Product(name: "Foo", type: .library(.automatic), targets: targets)]
        let toolsVersion = ToolsVersion(string: "5.2")!
        let versions: [PackageCollectionsModel.Package.Version] = [
            .init(
                version: .init(stringLiteral: "2.1.0-beta.3"), packageName: "FooBar", targets: targets, products: products,
                toolsVersion: toolsVersion, minimumPlatformVersions: nil, verifiedCompatibility: nil, license: nil
            ),
            .init(
                version: .init(stringLiteral: "3.0.0-beta.1"), packageName: "FooBar", targets: targets, products: products,
                toolsVersion: toolsVersion, minimumPlatformVersions: nil, verifiedCompatibility: nil, license: nil
            ),
        ]

        XCTAssertNil(versions.latestRelease)
        XCTAssertEqual("3.0.0-beta.1", versions.latestPrerelease?.version.description)
    }

    func testNoLatestPrereleaseVersion() {
        let targets = [PackageCollectionsModel.Target(name: "Foo", moduleName: "Foo")]
        let products = [PackageCollectionsModel.Product(name: "Foo", type: .library(.automatic), targets: targets)]
        let toolsVersion = ToolsVersion(string: "5.2")!
        let versions: [PackageCollectionsModel.Package.Version] = [
            .init(
                version: .init(stringLiteral: "1.2.0"), packageName: "FooBar", targets: targets, products: products,
                toolsVersion: toolsVersion, minimumPlatformVersions: nil, verifiedCompatibility: nil, license: nil
            ),
            .init(
                version: .init(stringLiteral: "2.0.1"), packageName: "FooBar", targets: targets, products: products,
                toolsVersion: toolsVersion, minimumPlatformVersions: nil, verifiedCompatibility: nil, license: nil
            ),
            .init(
                version: .init(stringLiteral: "2.1.0"), packageName: "FooBar", targets: targets, products: products,
                toolsVersion: toolsVersion, minimumPlatformVersions: nil, verifiedCompatibility: nil, license: nil
            ),
        ]

        XCTAssertEqual("2.1.0", versions.latestRelease?.version.description)
        XCTAssertNil(versions.latestPrerelease)
    }

    func test_sourceOK() throws {
        do {
            let source = PackageCollectionsModel.CollectionSource(type: .json, url: URL(string: "https://package-collection-tests.com/test.json")!)
            XCTAssertNil(source.validate())
        }

        do {
            fixture(name: "Collections") { directoryPath in
                // File must exist in local FS
                let path = directoryPath.appending(components: "JSON", "good.json")

                let source = PackageCollectionsModel.CollectionSource(type: .json, url: path.asURL)
                XCTAssertNil(source.validate())
            }
        }
    }

    func test_source_localFileDoesNotExist() throws {
        do {
            let source = PackageCollectionsModel.CollectionSource(type: .json, url: URL(fileURLWithPath: "/foo/bar"))

            let messages = source.validate()!
            XCTAssertEqual(1, messages.count)

            guard case .error = messages[0].level else {
                return XCTFail("Expected .error")
            }
            XCTAssertNotNil(messages[0].message.range(of: "non-local files not allowed", options: .caseInsensitive))
        }
    }
}
