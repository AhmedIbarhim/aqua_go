import 'privacy_policy_models.dart';

const PrivacyPolicyText privacyPolicyTextsEn = PrivacyPolicyText(
  title: 'Privacy Policy',
  intro:
      'This Privacy Policy explains how AquaGo collects and uses personal data of users who use the AquaGo app or benefit from mobile washing services (collectively referred to as the "Platform").\n\nWe place great importance on protecting your personal data and are committed to handling it with care, maintaining its security, and complying with applicable laws and regulations. Please read this policy carefully, as it contains important information about how your data is used and your rights related to it.',
  sections: [
    PrivacyPolicySection(
      title: 'Scope of Application',
      content:
          'This policy applies only to the AquaGo platform and does not extend to any third-party sites or services that may be accessed through links within the app. Upon leaving the Platform, we do not control how those entities use your data.',
    ),
    PrivacyPolicySection(
      title: 'Consent',
      content:
          'By using the AquaGo app or requesting our services, you agree – where applicable – to the collection, use, and transfer of your personal data as described in this policy.',
    ),
    PrivacyPolicySection(
      title: 'Data We Collect',
      content:
          'We may collect the following types of data:\n- Name\n- Mobile Number\n- Geographical Location (to perform the service)\n- Vehicle Details\n- Order and Payment Data',
    ),
    PrivacyPolicySection(
      title: 'How We Use Data',
      content:
          'We use your data for the following purposes:\n- Providing mobile washing services\n- Managing orders and reservations\n- Improving service quality\n- Communicating with you regarding orders or offers',
    ),
    PrivacyPolicySection(
      title: 'Data Sharing',
      content:
          'We do not sell your data to any third party.\nWe may share your data only with:\n- Operations team (to perform the service)\n- Payment service providers',
    ),
    PrivacyPolicySection(
      title: 'Data Protection',
      content:
          'We are committed to taking appropriate technical and organizational measures to protect your data from unauthorized access or illegal use.',
    ),
    PrivacyPolicySection(
      title: 'Data Retention',
      content:
          'We retain your data only for as long as necessary to provide the service or comply with legal requirements.',
    ),
    PrivacyPolicySection(
      title: 'Your Rights',
      content:
          'You have the right to:\n- Request access to your data\n- Request its modification\n- Request its deletion',
    ),
    PrivacyPolicySection(
      title: 'Modifications',
      content:
          'We reserve the right to modify this policy at any time, and the updated version will be published via the app.',
    ),
    PrivacyPolicySection(
      title: 'Contact',
      content: 'For privacy-related inquiries: customer.support@aquago.sa',
    ),
  ],
  footer:
      'By using the Platform, you acknowledge your agreement to this policy',
);
