Map<String, dynamic> purchaserInfoTestDataU = {
  "entitlements": {
    "all": {
      "pro": {
        "identifier": "pro",
        "isActive": false,
        "willRenew": false,
        "periodType": "PeriodType.normal",
        "latestPurchaseDate": "2020-02-25T08:33:34.000Z",
        "originalPurchaseDate": "2020-02-25T07:59:39.000Z",
        "expirationDate": "2020-02-25T08:36:34.000Z",
        "store": "Google PlayStore",
        "productIdentifier": "rc_sub_1m",
        "isSandbox": true,
        "unsubscribeDetectedAt": "2020-02-25T08:40:20.000Z",
        "billingIssueDetectedAt": null
      }
    },
    "active": {}
  },
  "latestExpirationDate": "2020-02-25T08:36:34.000Z",
  "allExpirationDates": {"rc_sub_1m": "2020-02-25T08:36:34.000Z"},
  "allPurchaseDates": {"rc_sub_1m": "2020-02-25T08:33:34.000Z"},
  "activeSubscriptions": [],
  "allPurchasedProductIdentifiers": ["rc_sub_1m"],
  "firstSeen": "2020-02-22T13:28:06.000Z",
  "originalAppUserId": "test@test.com",
  "requestDate": "2020-04-03T12:51:01.000Z",
  "originalApplicationVersion": null
};

Map<String, dynamic> purchaserInfoTestDataS = {
  "entitlements": {
    "all": {
      "pro": {
        "identifier": "pro",
        "isActive": false,
        "willRenew": false,
        "periodType": "PeriodType.normal",
        "latestPurchaseDate": "2020-02-25T08:33:34.000Z",
        "originalPurchaseDate": "2020-02-25T07:59:39.000Z",
        "expirationDate": "2020-02-25T08:36:34.000Z",
        "store": "Google PlayStore",
        "productIdentifier": "rc_sub_1m",
        "isSandbox": true,
        "unsubscribeDetectedAt": "2020-02-25T08:40:20.000Z",
        "billingIssueDetectedAt": null
      }
    },
    "active": {
      "pro": {
        "identifier": "pro",
        "isActive": true,
        "willRenew": false,
        "periodType": "PeriodType.normal",
        "latestPurchaseDate": "2020-02-25T08:33:34.000Z",
        "originalPurchaseDate": "2020-02-25T07:59:39.000Z",
        "expirationDate": "2020-02-25T08:36:34.000Z",
        "store": "Google PlayStore",
        "productIdentifier": "rc_sub_1m",
        "isSandbox": true,
        "unsubscribeDetectedAt": "2020-02-25T08:40:20.000Z",
        "billingIssueDetectedAt": null
      }
    }
  },
  "latestExpirationDate": "2020-02-25T08:36:34.000Z",
  "allExpirationDates": {"rc_sub_1m": "2020-02-25T08:36:34.000Z"},
  "allPurchaseDates": {"rc_sub_1m": "2020-02-25T08:33:34.000Z"},
  "activeSubscriptions": [],
  "allPurchasedProductIdentifiers": ["rc_sub_1m"],
  "firstSeen": "2020-02-22T13:28:06.000Z",
  "originalAppUserId": "test@test.com",
  "requestDate": "2020-04-03T12:51:01.000Z",
  "originalApplicationVersion": null
};

Map<String, dynamic> offeringsTestData = {
  "current": {
    "identifier": "Offering",
    "serverDescription": "RevenueCat Pro offering",
    "availablePackages": [
      {
        "identifier": "rc_monthly",
        "packageType": "COOK",
        "product": {
          "identifier": "rc_sub_1m",
          "description": "100 orders bundle",
          "title":
              "100 orders bundle",
          "price": 500.00,
          "price_string": "R 500,00",
          "currency_code": "ZAR",
          "intro_price": 0,
          "intro_price_string": "R0,00",
          "intro_price_period": "P1W",
          "intro_pric_period_unit": "DAY",
          "intro_price_period_number_of_units": 7,
          "intro_price_cycles": 1,
        },
        "offeringIdentifier": "Offering",
      },
      {
        "identifier": "rc_monthly2",
        "packageType": "CHEF",
        "product": {
          "identifier": "rc_sub_1m2",
          "description": "500 orders bundle",
          "title":
          "500 orders bundle",
          "price": 2000.00,
          "price_string": "R 2000,00",
          "currency_code": "ZAR",
          "intro_price": 0,
          "intro_price_string": "R0,00",
          "intro_price_period": "P1W",
          "intro_pric_period_unit": "DAY",
          "intro_price_period_number_of_units": 7,
          "intro_price_cycles": 1,
        },
        "offeringIdentifier": "Offering",
      },
      {
        "identifier": "rc_monthly2",
        "packageType": "MICHELIN",
        "product": {
          "identifier": "rc_sub_1m2",
          "description": "1000 orders bundle",
          "title":
          "1000 orders bundle",
          "price": 3000.00,
          "price_string": "R 3000,00",
          "currency_code": "ZAR",
          "intro_price": 0,
          "intro_price_string": "R0,00",
          "intro_price_period": "P1W",
          "intro_pric_period_unit": "DAY",
          "intro_price_period_number_of_units": 7,
          "intro_price_cycles": 1,
        },
        "offeringIdentifier": "Offering",
      }
    ],
  },
  "all": {
    "Offering": {
      "identifier": "Offering",
      "serverDescription": "RevenueCat Pro offering",
      "availablePackages": [
        {
          "identifier": "rc_monthly",
          "packageType": "COOK",
          "product": {
            "identifier": "rc_sub_1m",
            "description": "100 orders bundle",
            "title":
            "100 orders bundle",
            "price": 500.00,
            "price_string": "R 500,00",
            "currency_code": "ZAR",
            "intro_price": 0,
            "intro_price_string": "R0,00",
            "intro_price_period": "P1W",
            "intro_pric_period_unit": "DAY",
            "intro_price_period_number_of_units": 7,
            "intro_price_cycles": 1,
          },
          "offeringIdentifier": "Offering",
        },
        {
          "identifier": "rc_monthly2",
          "packageType": "CHEF",
          "product": {
            "identifier": "rc_sub_1m2",
            "description": "500 orders bundle",
            "title":
            "500 orders bundle",
            "price": 2000.00,
            "price_string": "R 2000,00",
            "currency_code": "ZAR",
            "intro_price": 0,
            "intro_price_string": "R0,00",
            "intro_price_period": "P1W",
            "intro_pric_period_unit": "DAY",
            "intro_price_period_number_of_units": 7,
            "intro_price_cycles": 1,
          },
          "offeringIdentifier": "Offering",
        },
        {
          "identifier": "rc_monthly2",
          "packageType": "MICHELIN",
          "product": {
            "identifier": "rc_sub_1m2",
            "description": "1000 orders bundle",
            "title":
            "1000 orders bundle",
            "price": 3000.00,
            "price_string": "R 3000,00",
            "currency_code": "ZAR",
            "intro_price": 0,
            "intro_price_string": "R0,00",
            "intro_price_period": "P1W",
            "intro_pric_period_unit": "DAY",
            "intro_price_period_number_of_units": 7,
            "intro_price_cycles": 1,
          },
          "offeringIdentifier": "Offering",
        }
      ],
    }
  }
};
