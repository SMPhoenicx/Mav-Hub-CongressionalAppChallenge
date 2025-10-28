//
//  TermsView.swift
//  NewMavApp
//
//  Created by Jack Vu on 1/22/25.
//

import SwiftUI

struct TermsAndConditionsView: View {
    let termsText = """
    Terms and Conditions for The Quad App

    Effective Date: January 23, 2025

    Welcome to The Quad, a social networking app designed exclusively for students at [Your High School]. By accessing or using The Quad ("the App"), you agree to these Terms and Conditions ("Terms"). Please read them carefully. If you do not agree to these Terms, do not use the App.

    1. Eligibility

    1.1. You must be a current student at St. John's School to use The Quad.
    1.2. Users under 13 years of age are prohibited from using the App in compliance with the Children’s Online Privacy Protection Act (COPPA).

    2. Account Responsibilities

    2.1. You are responsible for maintaining the confidentiality of your account and password.
    2.2. You agree to provide accurate information when creating your account.
    2.3. Sharing your account with others is prohibited.

    3. Community Guidelines

    3.1. You agree to:

    Use the App in a respectful and lawful manner.

    Avoid posting content that is abusive, defamatory, obscene, discriminatory, or illegal.

    Refrain from bullying, harassment, or impersonating others.

    Respect the intellectual property rights of others.

    3.2. Content flagged as inappropriate by users or administrators may be removed, and your account may be suspended or terminated at the discretion of the App administrators.

    4. User-Generated Content

    4.1. You retain ownership of the content you post on The Quad.
    4.2. By posting content, you grant The Quad a non-exclusive, worldwide, royalty-free license to use, display, and share your content within the App.
    4.3. You agree not to post:

    Any content that infringes on intellectual property rights.

    Personal information of others without their consent.

    Malicious software, spam, or deceptive links.

    5. Privacy

    5.1. The Quad collects and uses personal data in accordance with its Privacy Policy https://sjsmavhub.github.io/mavhubprivacy.github.io/.
    5.2. Data collected is stored securely and will not be shared with third parties except as required by law.
    5.3. The Quad complies with the Family Educational Rights and Privacy Act (FERPA) and other applicable laws in Houston, Texas.

    6. Reputation and Leaderboard System

    6.1. The App includes a reputation system based on user interactions.
    6.2. Manipulation of the reputation system (e.g., creating multiple accounts) is prohibited.
    6.3. Reputation points and leaderboard rankings have no monetary value and cannot be transferred.

    7. Termination

    7.1. The Quad reserves the right to suspend or terminate accounts that violate these Terms.
    7.2. Users may request account deletion by contacting support at [Insert Email Address].

    8. Liability and Disclaimer

    8.1. The App is provided "as is," and The Quad makes no guarantees regarding its availability or functionality.
    8.2. The Quad is not responsible for:

    Any loss or damage resulting from use of the App.

    Actions or content posted by other users.

    9. Changes to Terms

    9.1. The Quad reserves the right to update these Terms at any time.
    9.2. Users will be notified of changes via in-app notifications or email.

    10. Governing Law

    10.1. These Terms are governed by the laws of the State of Texas.
    10.2. Any disputes shall be resolved in the courts located in Houston, Texas.

    11. Contact Us

    If you have questions about these Terms, please contact us at [Insert Contact Information].

    By using The Quad, you acknowledge that you have read, understood, and agreed to these Terms and Conditions.
    """

    var body: some View {
        ScrollView {
            Text(termsText)
                .padding()
                .font(.body)
                .multilineTextAlignment(.leading)
        }
        .navigationTitle("Terms and Conditions")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct TermsAndConditionsView_Previews: PreviewProvider {
    static var previews: some View {
        TermsAndConditionsView()
    }
}
