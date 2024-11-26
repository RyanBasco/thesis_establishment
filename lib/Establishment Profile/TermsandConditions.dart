import 'package:flutter/material.dart';

class TermsAndConditions extends StatefulWidget {
  const TermsAndConditions({super.key});

  @override
  _TermsAndConditionsState createState() => _TermsAndConditionsState();
}

class _TermsAndConditionsState extends State<TermsAndConditions> {
  bool _isInformationExpanded = false;
  bool _isUsageExpanded = false;
  bool _isDataSharingExpanded = false;
  bool _isSecurityExpanded = false;
  bool _isRetentionExpanded = false;
  bool _isRightsExpanded = false;
  bool _isChangesExpanded = false;
  bool _isUseAppExpanded = false;
  bool _isUserResponsibilitiesExpanded = false;
  bool _isQRCodeUseExpanded = false;
  bool _isIntellectualPropertyExpanded = false;
  bool _isNoWarrantyExpanded = false;
  bool _isTerminationExpanded = false;
  bool _isGoverningLawExpanded = false;
  bool _isEntireAgreementExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFEEFFA9),
              Color(0xFFDBFF4C),
              Color(0xFF51F643),
            ],
            stops: [0.15, 0.54, 1.0],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const SizedBox(height: 20),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context); // Navigate to the previous page
                      },
                      child: Container(
                        padding: const EdgeInsets.all(
                            12.0), // Padding inside the circle
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.black,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Privacy Policy',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 10),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14.5,
                      fontFamily: 'Poppins',
                    ),
                    children: [
                      TextSpan(
                        text:
                            'We value your privacy and are committed to protecting your business data. This Privacy Policy outlines how we collect, use, and protect your information when you use Isla G as a registered establishment.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                buildExpandableSection(
                  title: 'Information We Collect',
                  isExpanded: _isInformationExpanded,
                  onPressed: () {
                    setState(() {
                      _isInformationExpanded = !_isInformationExpanded;
                    });
                  },
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Business Information:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: 'Poppins'),
                            ),
                            TextSpan(
                              text:
                                  'When registering on Isla G, we collect business information such as the name of your establishment, type, sub-category, city/municipality, barangay, contact number, email address, and password for your account.',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: 'Poppins'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Transaction Data:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: 'Poppins'),
                            ),
                            TextSpan(
                              text:
                                  'We log transaction data related to services provided to tourists, including QR code scans, spending records, and categories of services.',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: 'Poppins'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'QR Code Data:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: 'Poppins'),
                            ),
                            TextSpan(
                              text:
                                  'We gather information related to QR codes generated by tourists and scanned by your establishment for transaction validation.',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: 'Poppins'),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
                const SizedBox(height: 7.5),
                buildExpandableSection(
                  title: 'How We Use Your Information',
                  isExpanded: _isUsageExpanded,
                  onPressed: () {
                    setState(() {
                      _isUsageExpanded = !_isUsageExpanded;
                    });
                  },
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Service Provision and Improvement:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: 'Poppins'),
                            ),
                            TextSpan(
                              text:
                                  'Your data enables us to provide transaction validation, spending analysis, and real-time insights to improve tourism management.',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: 'Poppins'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Data Analysis: ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: 'Poppins'),
                            ),
                            TextSpan(
                              text:
                                  'We analyze transaction data to understand spending trends, generate reports, and provide insights beneficial to the local tourism sector.',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: 'Poppins'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Communication: ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: 'Poppins'),
                            ),
                            TextSpan(
                              text:
                                  'We may contact you with updates on your account, service offerings, and important notifications related to Isla G.',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: 'Poppins'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Compliance and Legal Obligations: ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: 'Poppins'),
                            ),
                            TextSpan(
                              text:
                                  'Your information may be used to comply with regulations and enforce our terms.',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: 'Poppins'),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
                const SizedBox(height: 7.5),
                buildExpandableSection(
                  title: 'Data Sharing and Disclosure',
                  isExpanded: _isDataSharingExpanded,
                  onPressed: () {
                    setState(() {
                      _isDataSharingExpanded = !_isDataSharingExpanded;
                    });
                  },
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'With PEDO:',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text:
                                  'Authorized officers may access your establishment’s information and transaction data to ensure compliance with local policies.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Legal Compliance:',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text:
                                  'We may disclose your information if required by law or in response to legal proceedings.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
                const SizedBox(height: 7.5),
                buildExpandableSection(
                  title: 'Data Security',
                  isExpanded: _isSecurityExpanded,
                  onPressed: () {
                    setState(() {
                      _isSecurityExpanded = !_isSecurityExpanded;
                    });
                  },
                  content: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'We use technical and organizational measures to protect your data from unauthorized access, alteration, or disclosure.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
                const SizedBox(height: 7.5),
                buildExpandableSection(
                  title: 'Data Retention',
                  isExpanded: _isRetentionExpanded,
                  onPressed: () {
                    setState(() {
                      _isRetentionExpanded = !_isRetentionExpanded;
                    });
                  },
                  content: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your business data is retained as long as needed to provide services, meet legal requirements, and maintain records for reporting purposes. Should you cancel your business registration on Isla G, your account information will be archived but permanently retained for record-keeping.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
                const SizedBox(height: 7.5),
                buildExpandableSection(
                  title: 'Your Rights',
                  isExpanded: _isRightsExpanded,
                  onPressed: () {
                    setState(() {
                      _isRightsExpanded = !_isRightsExpanded;
                    });
                  },
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Access and Update: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            TextSpan(
                              text:
                                  'You can access and update your business information through Isla G.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Business Closure: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            TextSpan(
                              text:
                                  'If you cancel your account, your establishment’s data will be archived, and all transaction records will remain indefinitely in the system for reporting purposes.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
                const SizedBox(height: 7.5),
                buildExpandableSection(
                  title: 'Changes to This Privacy Policy',
                  isExpanded: _isChangesExpanded,
                  onPressed: () {
                    setState(() {
                      _isChangesExpanded = !_isChangesExpanded;
                    });
                  },
                  content: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'We may update this policy as needed. Significant changes will be communicated by posting on Isla G and updating the date at the top.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'If you have any questions, please contact us at [islag@gmail.com].',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14.5,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Terms and Conditions',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Welcome to IslaBiz. By registering your establishment and using IslaBiz, you agree to comply with and be bound by these Terms and Conditions.',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14.5,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 20),
                buildExpandableSection(
                  title: 'Use of IslaBiz',
                  isExpanded: _isUseAppExpanded,
                  onPressed: () {
                    setState(() {
                      _isUseAppExpanded = !_isUseAppExpanded;
                    });
                  },
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Eligibility: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            TextSpan(
                              text:
                                  'To register as an establishment on IslaBiz, you must be a recognized tourism-related business within the areas covered by the platform. By using the app, you confirm that your business meets this requirement.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Account Registration: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            TextSpan(
                              text:
                                  ' You must provide accurate and complete information during registration, including your establishment’s name, type, contact information, and other required details. Ensure that this information remains updated to provide accurate service.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Prohibited Conduct: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            TextSpan(
                              text:
                                  'You agree not to use IslaBiz for any unlawful or prohibited activities, including but not limited to submitting false information, unauthorized data sharing, or engaging in activities that violate intellectual property rights.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
                const SizedBox(height: 7.5),
                buildExpandableSection(
                  title: 'Establishment Responsibilities',
                  isExpanded: _isUserResponsibilitiesExpanded,
                  onPressed: () {
                    setState(() {
                      _isUserResponsibilitiesExpanded =
                          !_isUserResponsibilitiesExpanded;
                    });
                  },
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Data Accuracy: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            TextSpan(
                              text:
                                  'Ensure that all transaction and QR code data you record through Isla G is accurate. Accurate data entry ensures quality reporting and effective insights.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                       const SizedBox(height: 10),
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Account Security:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            TextSpan(
                              text:
                                  'You are responsible for maintaining the confidentiality of your account credentials. Unauthorized access and misuse of your account are your responsibility, and you agree to notify us immediately in the case of a security breach.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Compliance: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            TextSpan(
                              text:
                                  ' Your establishment agrees to comply with all applicable laws and regulations related to tourism services and data handling.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
                const SizedBox(height: 7.5),
                buildExpandableSection(
                  title: 'QR Code Use for Transactions',
                  isExpanded: _isQRCodeUseExpanded,
                  onPressed: () {
                    setState(() {
                      _isQRCodeUseExpanded = !_isQRCodeUseExpanded;
                    });
                  },
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Scanning and Validation:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            TextSpan(
                              text:
                                  ' Establishments are required to use IslaBiz to validate tourist transactions by scanning QR codes generated by tourists. This feature should only be used for authorized, legitimate transactions and not for any unauthorized purposes.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Data Usage:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            TextSpan(
                              text:
                                  ' Transaction data collected through QR code scans will be used for tourism insights and analysis. Ensure that only approved personnel within your establishment have access to this data.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10,)
                    ],
                  ),
                ),
                const SizedBox(height: 7.5),
                buildExpandableSection(
                  title: 'Intellectual Property',
                  isExpanded: _isIntellectualPropertyExpanded,
                  onPressed: () {
                    setState(() {
                      _isIntellectualPropertyExpanded =
                          !_isIntellectualPropertyExpanded;
                    });
                  },
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Ownership: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            TextSpan(
                              text:
                                  'All content, features, and functionalities of IslaBiz are the property of IslaBiz or its licensors and are protected by intellectual property laws.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'License: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            TextSpan(
                              text:
                                  'IslaBiz grants you a limited, non-exclusive, non-transferable license to use the platform solely for tourism-related services in line with these Terms and Conditions.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
                const SizedBox(height: 7.5),
                buildExpandableSection(
                  title: 'Disclaimers and Limitation of Liability',
                  isExpanded: _isNoWarrantyExpanded,
                  onPressed: () {
                    setState(() {
                      _isNoWarrantyExpanded = !_isNoWarrantyExpanded;
                    });
                  },
                  content:  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'No Warranty: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            TextSpan(
                              text:
                                  'IslaBiz is provided "as is" and "as available" without any warranties of any kind, either express or implied.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10,),
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Limitation of Liability: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            TextSpan(
                              text:
                                  'To the fullest extent permitted by law, IslaBiz will not be liable for any indirect, incidental, special, consequential, or punitive damages, or any loss of profits or revenues, whether incurred directly or indirectly, resulting from your use of the platform.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10,)
                    ],
                  ),
                ),
                const SizedBox(height: 7.5),
                buildExpandableSection(
                  title: 'Termination and Data Retention',
                  isExpanded: _isGoverningLawExpanded,
                  onPressed: () {
                    setState(() {
                      _isGoverningLawExpanded = !_isGoverningLawExpanded;
                    });
                  },
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Termination by You: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            TextSpan(
                              text:
                                  'If you wish to terminate your account, you may request deactivation. Please note that while your account will be archived, all transaction data will be permanently retained in the system for record-keeping and analysis purposes.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Termination by Us: ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            TextSpan(
                              text:
                                  ' IslaBiz reserves the right to suspend or terminate your access if you violate these Terms and Conditions or engage in unauthorized activities on the platform.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
                const SizedBox(height: 7.5),
                buildExpandableSection(
                  title: 'Changes to These Terms',
                  isExpanded: _isTerminationExpanded,
                  onPressed: () {
                    setState(() {
                      _isTerminationExpanded = !_isTerminationExpanded;
                    });
                  },
                  content: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'We may update these Terms and Conditions from time to time. Any significant changes will be communicated by posting on Isla G and updating the date at the top of this document.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
                const SizedBox(height: 7.5),
                buildExpandableSection(
                  title: 'Governing Law',
                  isExpanded: _isEntireAgreementExpanded,
                  onPressed: () {
                    setState(() {
                      _isEntireAgreementExpanded = !_isEntireAgreementExpanded;
                    });
                  },
                  content: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'These Terms and Conditions are governed by the laws of the Philippines, without regard to its conflict of law principles.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'For questions or concerns about these Terms and Conditions, please contact us at [islabiz@gmail.com].',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14.5,
                    fontFamily: 'Poppins',
                  ),
                ),
                SizedBox(
                  height: 30,
                )
              ])),
        ),
      ),
    );
  }

  Widget buildSection({required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 10),
        Text(
          content,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14.5,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }

  Widget buildExpandableSection({
    required String title,
    required bool isExpanded,
    required VoidCallback onPressed,
    required Widget content,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          color: const Color(0xFF288F13), // Bar color
          child: Column(
            children: [
              GestureDetector(
                onTap: onPressed,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                      Icon(
                        isExpanded ? Icons.remove : Icons.add,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: isExpanded ? null : 0,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: content,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
