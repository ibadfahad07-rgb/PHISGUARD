import 'package:flutter/material.dart';

class EducationPage extends StatelessWidget {
  const EducationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Learn About Phishing',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Understanding how phishing works is one of the best '
              'defenses against it. Tap a topic below to learn more.',
              style: TextStyle(fontSize: 15, color: Colors.grey),
            ),
          ),

          _buildTopic(
            icon: Icons.help_outline,
            title: 'What Is Phishing?',
            content:
                'Phishing is a type of scam where attackers pretend to be '
                'a trustworthy person or organization — like your bank, '
                'a coworker, or a well-known company — in order to trick '
                'you into giving up sensitive information such as '
                'passwords, credit card numbers, or personal details.\n\n'
                'Phishing most often happens through email, text '
                'messages, or fake websites, but it can also happen '
                'through phone calls or social media messages.',
          ),

          _buildTopic(
            icon: Icons.warning_amber_rounded,
            title: 'Common Phishing Tactics',
            content:
                '• Creating a false sense of urgency ("Act now or your '
                'account will be suspended")\n\n'
                '• Impersonating a trusted brand or person\n\n'
                '• Using generic greetings like "Dear Customer" instead '
                'of your real name\n\n'
                '• Asking you to click a link and "verify" or "confirm" '
                'your information\n\n'
                '• Threatening consequences, such as account closure or '
                'legal action, if you don\'t act quickly\n\n'
                '• Offering something that seems too good to be true, '
                'like a prize or refund',
          ),

          _buildTopic(
            icon: Icons.link,
            title: 'Spotting Suspicious Links',
            content:
                'Before clicking any link, look closely at it:\n\n'
                '• Does the domain actually match the company it claims '
                'to be from? (e.g. "paypal-secure-login.com" is NOT '
                'PayPal)\n\n'
                '• Is it using HTTPS? Legitimate sites almost always do.\n\n'
                '• Are there unusual characters, misspellings, or extra '
                'words in the domain?\n\n'
                '• Is the link unusually long or full of random '
                'characters?\n\n'
                'On most devices, you can press and hold a link to '
                'preview the actual destination before tapping it.',
          ),

          _buildTopic(
            icon: Icons.login,
            title: 'Fake Login Pages',
            content:
                'Attackers often build fake websites that look identical '
                'to real login pages (like Gmail, banking sites, or '
                'social media) to steal your username and password when '
                'you type them in.\n\n'
                'Warning signs include:\n\n'
                '• The web address doesn\'t match the real site\n\n'
                '• You arrived at the login page by clicking a link in '
                'an email or message, rather than typing the address '
                'yourself\n\n'
                '• The page asks for more information than a normal '
                'login would (like your full card number)\n\n'
                'When in doubt, don\'t use the link — open the app or '
                'type the website address directly into your browser.',
          ),

          _buildTopic(
            icon: Icons.psychology_outlined,
            title: 'Social Engineering',
            content:
                'Not all attacks rely on fake links. Social engineering '
                'is when someone manipulates you psychologically into '
                'taking an action — like sending money, sharing a code, '
                'or giving up information — usually by pretending to be '
                'someone you trust or by creating pressure and urgency.\n\n'
                'Examples include a scammer pretending to be a coworker, '
                'a fake tech support call claiming your device is '
                'infected, or a message pretending to be from a family '
                'member in an emergency.\n\n'
                'The best defense is to slow down and verify — contact '
                'the person or organization directly through a method '
                'you already trust, not through the contact info '
                'provided in the suspicious message itself.',
          ),

          _buildTopic(
            icon: Icons.password,
            title: 'Password Security',
            content:
                '• Use a different password for every important '
                'account\n\n'
                '• Use long passwords or passphrases rather than short, '
                'guessable ones\n\n'
                '• Consider using a password manager to generate and '
                'store strong passwords\n\n'
                '• Never share your password with anyone — legitimate '
                'companies will never ask you for it over email or '
                'phone\n\n'
                '• Change your password immediately if you suspect an '
                'account has been compromised',
          ),

          _buildTopic(
            icon: Icons.verified_user_outlined,
            title: 'Multi-Factor Authentication (MFA)',
            content:
                'MFA adds a second layer of protection beyond just your '
                'password — usually a code sent to your phone, an '
                'authenticator app, or a biometric check like a '
                'fingerprint.\n\n'
                'Even if a phishing attack successfully steals your '
                'password, MFA can stop an attacker from actually '
                'accessing your account.\n\n'
                'Turn on MFA wherever it\'s offered, especially for '
                'email, banking, and social media accounts — these are '
                'often used as a gateway to compromise your other '
                'accounts.',
          ),

          _buildTopic(
            icon: Icons.shield_outlined,
            title: 'Safe Browsing Habits',
            content:
                '• Keep your browser and apps updated\n\n'
                '• Avoid clicking links or downloading attachments from '
                'unexpected or unfamiliar senders\n\n'
                '• Type important website addresses directly rather than '
                'clicking links in emails\n\n'
                '• Be cautious on public Wi-Fi — avoid logging into '
                'sensitive accounts on unsecured networks\n\n'
                '• When unsure about a link, scan it with PhishGuard '
                'before clicking',
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTopic({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        leading: Icon(icon),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            content,
            style: const TextStyle(fontSize: 14.5, height: 1.4),
          ),
        ],
      ),
    );
  }
}