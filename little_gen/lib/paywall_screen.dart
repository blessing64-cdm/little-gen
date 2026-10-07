import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'billing_service.dart';

class PaywallScreen extends StatelessWidget {
  final Widget? nextScreen;

  const PaywallScreen({Key? key, this.nextScreen}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<BillingService>(
      builder: (context, billing, child) {
        // If unlocked while on paywall, automatically proceed if nextScreen is provided
        if (billing.isPremiumUnlocked && nextScreen != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => nextScreen!),
            );
          });
        }

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4A0E4E), Color(0xFF81055B), Color(0xFF2C003E)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.2),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.amber.withOpacity(0.4),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const Text(
                              '👑',
                              style: TextStyle(fontSize: 64),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Unlock Full Access!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'One-time purchase • Unlock all current & future activities!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.amber.shade200,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 28),
                          // Feature List Card
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              children: [
                                _FeatureRow(icon: '✏️', title: 'Trace & Write Letters & Numbers'),
                                const Divider(color: Colors.white24, height: 16),
                                _FeatureRow(icon: '🔤', title: 'Spelling A to Z'),
                                const Divider(color: Colors.white24, height: 16),
                                _FeatureRow(icon: '🧩', title: 'Word Builder Puzzles'),
                                const Divider(color: Colors.white24, height: 16),
                                _FeatureRow(icon: '📖', title: 'Interactive Story Time'),
                                const Divider(color: Colors.white24, height: 16),
                                _FeatureRow(icon: '🎵', title: 'ABC Song & Music'),
                                const Divider(color: Colors.white24, height: 16),
                                _FeatureRow(icon: '🔷', title: 'Shape Matching & Logic Games'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),
                          if (billing.statusMessage != null) ...[
                            Text(
                              billing.statusMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.amber, fontSize: 14),
                            ),
                            const SizedBox(height: 12),
                          ],
                          // CTA Purchase Button
                          SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton(
                              onPressed: billing.isPurchasing
                                  ? null
                                  : () {
                                      if (billing.isPremiumUnlocked) {
                                        if (nextScreen != null) {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(builder: (_) => nextScreen!),
                                          );
                                        } else {
                                          Navigator.pop(context);
                                        }
                                      } else {
                                        billing.buyPremiumUpgrade();
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: billing.isPremiumUnlocked
                                    ? Colors.green.shade600
                                    : const Color(0xFFFFB703),
                                foregroundColor: Colors.black,
                                elevation: 8,
                                shadowColor: Colors.amber.withOpacity(0.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: billing.isPurchasing
                                  ? const CircularProgressIndicator(color: Colors.black)
                                  : Text(
                                      billing.isPremiumUnlocked
                                          ? 'UNLOCKED! TAP TO PLAY 🎉'
                                          : 'UNLOCK EVERYTHING — ${billing.premiumProduct?.price ?? '\$3.99'}',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: billing.isPremiumUnlocked ? Colors.white : Colors.black,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: billing.isPurchasing
                                ? null
                                : () => billing.restorePurchase(),
                            child: const Text(
                              'Restore Previous Purchase',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                  // Close X Button
                  Positioned(
                    top: 10,
                    right: 10,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final String icon;
  final String title;

  const _FeatureRow({Key? key, required this.icon, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 22)),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Icon(Icons.check_circle, color: Colors.amber, size: 20),
      ],
    );
  }
}
