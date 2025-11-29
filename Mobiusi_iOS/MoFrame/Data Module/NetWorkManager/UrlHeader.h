//
//  UrlHeader.h
//  Translate
//
//  Created by 11 on 16/8/22.
//  Copyright © 2016年 MS. All rights reserved.
//

#ifndef UrlHeader_h
#define UrlHeader_h


#ifdef DEBUG
#define API_HOST @"http://api.dev.mobiwusi.com"
// #define API_HOST @"https://app-api.mobiwusi.com"
#else
// #define API_HOST @"https://app-api.mobiwusi.com"
#define API_HOST @"http://api.dev.mobiwusi.com"

#endif


#define service_agreements @"https://m.mobiwusi.com/index/serviceAgreements"
#define privacy_agreements @"https://m.mobiwusi.com/index/privacyAgreements"

#ifdef DEBUG
#define points_rule @"http://m.dev.mobiwusi.com/user/rule"
#else
#define points_rule @"https://m.mobiwusi.com/user/rule"
#endif

#define PRIVATE_KEY_STRING @"MIICdgIBADANBgkqhkiG9w0BAQEFAASCAmAwggJcAgEAAoGBANemrv06SK8B1WIp3qatENT5iI7aiqEIweFEdxJ6EBrPTYQbcjBPmE0vYedoTDUPlOJDVG3PdofpobaDP8quc8YJcDEsFEFWI0wOLJlKX8KbFKkyTbAOYhprm8wC+JrwBVdcS9cbU8N5fulCUp1hKCN2YjxqcIDzZ2Q7GHCxqpsdAgMBAAECgYAFtlycSJb0S9AjMYi8UYlImvOLFS7m5Rx9oxqkWqdijms3PKLhtLoMEV0+i/y4yxjehXoPDpfNMdsewotGCyj14YdVm5ZNRj3HgP5JY2hbahCtpJuaJtMAKg1zYDNgVMmKxBf2tMB+C5w1mlFX1mK5xemm2xJ7CcMOGz7mTn5i4QJBAO0VXgyvC1JSevijSgtVWqDhxohpHYUHrYBDtsd4LqFMSzKczq93fMyStxQUxDlzVlCMtYrNnQSPyNRJUykcN0MCQQDo24q6itXJjxWwZ+0UUC7+UGvpahBovavhFAnIEqFe9nWBwqzjIXeebvdpYhoUc+Sl6z0IusN0bqGNAG9RmM4fAkEAutMntd8KkOimNuCWLLAqJrVD+aK7vGT8eCLkGfO+6yRv7YZb6THDioHi+1QR/SPCVN9NAABfR4T2wTK28aJmeQJAIqDTZp5S4KCIpy0tUoICGwu2oIWHXywlrVkfg0NSAB9CpkNfFn/ZnBQAcwmFu1jovcvXzb6IZn41RBS2eTnyHQJAUnrQlfaMFOC7wTFCvRsJ4hmckuEg7SqjMNfEeqM1zKX6QEVENxF9lsb14clOkjiJ3x6Sv34dikeFMG/UQZ+f+A=="

/*#define PRIVATE_KEY_STRING @"MIICdQIBADANBgkqhkiG9w0BAQEFAASCAl8wggJbAgEAAoGBAKJk5qoQmDFJkPcQIk6W5Lj++pwwOCaHRa0FPHnLSb/PN7h9KnqdVOPNMy8hwzwothBDSs698fjJzL/9ky/H1hdcdwmQLZcd4vInVhlWcDoL2/pxrpa0ZR2r0iw6wVudXCTfVRmXTJnHS6C7myOpigs/nLLUFNDZX/hIBIYYuQTTAgMBAAECgYA5qSYV4IqJhZuJfhsQWJeh8Dc/2gc19vYQdzl/7WSkTIl2YksA+ng34pZ3978Az1vF7n7TZbJTKiQfT4RBhO1JEUFqSaJ5pQLXn+us/dVLnVKjQvcnE8IC59F5yn0uvuWirXBMBPRTCaCsl5eckZgi5yor4mlA9+iKQXfdL/FgkQJBANW5HroxZlK7BlIIgWZYOD/gsKlFXB8oBCS62IC7jyJ4PsPIi4NR+MZg4r4EeNveVZ3VcrQF0GnqUcaNBU0iiuUCQQDChH7hMrLsJ4pJkoogKo+vQ/TQMgYeaattvW3HMQUuB/GaZ7qID5NRiZ7PW9/h4iNuuHQF3O4/m//FJTpu4n1XAkAPMl6Q9rpD37CPXLN2x4cYY62sG5Z1UK8avX5viOagmNQ9r6Db8ZQy5ui4gjDl0WVdF7RUQKWVImg2Kgjadz5RAkBx8NS1q1H9XQf3IryALQ4vdxoPXk4RQIqnZJ/KX1+OYB7Y+EveaWk9COUax9Fz6lghAjEMQibY4dNHsw/wZgFPAkAkDOUzHqPe/9Tg3ujaiEDn44ETFSbGchBMtxJgAhqeKLFQM/ZDOcWRonwCA/O8G2HTSngxrsIF2NZnO6WjBGO3"*/

#endif /* UrlHeader_h */
  
