//
//  SPHSpec.swift
//  Clutch
//
//  Created by Nico Hämäläinen on 31/03/15.
//  Copyright (c) 2015 Solinor Oy. All rights reserved.
//

import Foundation
import Quick
import Nimble
import Clutch
import Alamofire

// Test values

let SPHServiceURL = "http://54.194.196.206:8081"
let SPHMerchantID = "test_merchantId"
let SPHAccountID = "test"
let SPHSignatureKeyId = "testKey"
let SPHSignatureSecret = "testSecret"

class SPHSpec: QuickSpec {
	override func spec() {
		// Test Data
		let validCards: [SPHCardType: [String]] = [
			.americanExpress: ["378282246310005", "371449635398431", "378734493671000"],
			.dinersClub:      ["30569309025904", "38520000023237"],
			.discover:        ["6011111111111117", "6011000990139424"],
			.jcb:             ["3530111333300000", "3566002020360505"],
			.masterCard:      ["5555555555554444", "5105105105105100"],
			.visa:            ["4444333322221111", "4012888888881881", "4222222222222"],
		]
		
		let invalidCards = ["123", "0935835", "82378493", "000000"]
        
        let expirationDateFormats = ["" : "",
            "0" : "0",
            "00" : "0",
            "1" : "1",
            "11" : "11/",
            "13" : "1",
            "23" : "2",
            "10/1" : "10/1", // try removing this one and run tests
            "10/" : "10/", // formatter has a state
            "8" : "08/",
            "10/13" : "10/13",
            "10/134" : "10/13",
            "10/1334" : "",
            "aas/df1" : "1"]
        
        let securityCodeFormats = ["" : "",
            "0" : "0",
            "00" : "00",
            "000" : "000",
            "0000" : "0000",
            "00000" : "0000",
            "41234" : "4123",
            "123412344234" : "",
            " 1 43 / 2k k nkm" : "1432"]
        
		// Reset Clutch credentials before testsuite
		beforeSuite {
            SPH.initSharedInstance(
                merchantId: SPHMerchantID,
                accountId: SPHAccountID,
                signatureKeyId: SPHSignatureKeyId,
                signatureSecret: SPHSignatureSecret,
                mobileApiAddress: SPHServiceURL
            )
			return
		}
        
        describe("Card Formatting for processing") {
            it("should remove illegal characters") {
                let actualCardNumber = SPH.sharedInstance.formattedCardNumberForProcessing("55555🐺5555a5554 44,. -4")
                expect(actualCardNumber).to(equal("5555555555554444"))
            }
            it("should do nothing if already formatted") {
                let actualCardNumber = SPH.sharedInstance.formattedCardNumberForProcessing("378282246310005")
                expect(actualCardNumber).to(equal("378282246310005"))
            }
        }
		
		// MARK: Card Recognition
		
		describe("Card Recognition") {
			it("should recognize basic card types from their numbers") {
				for (cardType, cardNumbers) in validCards {
					for cardNumber in cardNumbers {
						let foundType = SPH.sharedInstance.cardTypeForCardNumber(cardNumber)
						expect(foundType.rawValue).to(equal(cardType.rawValue))
					}
				}
			}
			
			it("shouldn't recognize invalid card numbers as any type") {
				for cardNumber in invalidCards {
					expect(SPH.sharedInstance.cardTypeForCardNumber(cardNumber)).to(equal(SPHCardType.invalid))
				}
			}
		}
		
        
		// MARK: Credit Card Validation
		
		describe("Card Validation") {
			it("should validate cards properly") {
				for (cardType, cardNumbers) in validCards {
					for cardNumber in cardNumbers {
						let isValid = SPH.sharedInstance.isValidCardNumber(cardNumber)
						expect(isValid).to(beTrue())
					}
				}
				
				for cardNumber in invalidCards {
					let isValid = SPH.sharedInstance.isValidCardNumber(cardNumber)
					expect(isValid).to(beFalse())
				}
			}
		}
        
        describe("Card Formatting") {
            it("should format cards properly with general rule") {
                let actualCardNumber = SPH.sharedInstance.formattedCardNumber("5555555555554444", cardType: SPHCardType.visa)
                expect(actualCardNumber).to(equal("5555 5555 5555 4444"))
            }
            it("should format AMEX using special rule") {
                let actualCardNumber = SPH.sharedInstance.formattedCardNumber("378282246310005", cardType: SPHCardType.americanExpress)
                expect(actualCardNumber).to(equal("3782 822463 10005"))
            }
        }
        
        // MARK: Expiration date formatting
        
        describe("Expiration date formatting") {
            it("should format dates as expected") {
                for (given, expected) in expirationDateFormats {
                    let actual = SPH.sharedInstance.formattedExpirationDate(given)
                    expect(actual).to(equal(expected))
                }
            }
        }
        
        // MARK: Security code formatting

        describe("Security code formatting") {
            it("Format security code as expected") {
                for (given, expected) in securityCodeFormats {
                    let actual = SPH.sharedInstance.formattedSecurityCode(given)
                    expect(actual).to(equal(expected))
                }
            }
        }
	}
}
