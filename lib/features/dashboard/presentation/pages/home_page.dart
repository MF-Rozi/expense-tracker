import 'package:expense_tracker/features/dashboard/presentation/blocs/dashboard_cubit.dart';
import 'package:expense_tracker/features/dashboard/presentation/blocs/dashboard_state.dart';
import 'package:expense_tracker/features/dashboard/presentation/widgets/record_entry_card.dart';
import 'package:expense_tracker/features/dashboard/presentation/widgets/summary_card.dart';
import 'package:expense_tracker/features/dashboard/presentation/widgets/wealth_trajectory_chart.dart';
import 'package:expense_tracker/features/transaction/presentation/widgets/transaction_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardCubit>().loadDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: BlocBuilder<DashboardCubit, DashboardState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF00113A),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () =>
                  context.read<DashboardCubit>().loadDashboardData(),
              color: const Color(0xFF00113A),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.zero,
                      child: Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: Color(0xFFE5E7EB),
                            child: Icon(
                              Icons.person,
                              color: Color(0xFF00113A),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'mfrozi',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF00113A),
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(
                              Icons.notifications_none,
                              color: Color(0xFF00113A),
                            ),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back! 👋',
                              style: GoogleFonts.manrope(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF00113A),
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Here is your monthly overview',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: const Color(0xFF444650),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SummaryCard(
                      totalBalance: state.totalBalance,
                      totalIncome: state.totalIncome,
                      totalExpense: state.totalExpense,
                    ),
                    const SizedBox(height: 24),
                    const WealthTrajectoryChart(),
                    const SizedBox(height: 24),
                    const RecordEntryCard(),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Transactions',
                          style: GoogleFonts.manrope(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF00113A),
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.push('/transactions'),
                          child: Text(
                            'See All',
                            style: GoogleFonts.manrope(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF006BB3),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (state.recentTransactions.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF191C1D).withAlpha(5),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 48,
                              color: const Color(0xFF757682).withAlpha(128),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No movements recorded yet',
                              style: GoogleFonts.manrope(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF00113A),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap the button below to add '
                              'your first transaction.',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: const Color(0xFF444650),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.recentTransactions.length,
                        itemBuilder: (context, index) {
                          final transaction = state.recentTransactions[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: TransactionCard(transaction: transaction),
                          );
                        },
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
