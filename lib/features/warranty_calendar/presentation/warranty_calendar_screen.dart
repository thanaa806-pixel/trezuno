import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:trezuno/features/products/domain/product_model.dart';
import 'package:trezuno/core/theme/app_typography.dart';

/// Warranty Calendar Screen for Trezuno application.
class WarrantyCalendarScreen extends StatefulWidget {
  static const routeName = '/warranty-calendar';

  const WarrantyCalendarScreen({super.key});

  @override
  State<WarrantyCalendarScreen> createState() => _WarrantyCalendarScreenState();
}

class _WarrantyCalendarScreenState extends State<WarrantyCalendarScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  // Current selected month/year
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  // Sample products for calendar demo
  late final List<Product> _productsWithExpirations;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeInAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _productsWithExpirations = Product.sampleProducts();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: AnimatedBuilder(
        animation: _fadeInAnimation,
        builder: (context, child) => FadeTransition(
          opacity: _fadeInAnimation,
          child: Column(
            children: [
              _buildMonthNavigation(),
              Expanded(child: _buildCalendarGrid()),
              if (_productsWithExpirations.isNotEmpty)
                _buildSelectedDateInfo(),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Warranty Calendar'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.go('/dashboard'),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          tooltip: 'Previous month',
          onPressed: _previousMonth,
        ),
        Text(
          '${_getMonthName(_selectedMonth)} $_selectedYear',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          tooltip: 'Next month',
          onPressed: _nextMonth,
        ),
      ],
    );
  }

  Widget _buildMonthNavigation() {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 12,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemBuilder: (context, index) {
          final month = index + 1;
          final isSelected = month == _selectedMonth;
          return InkWell(
            onTap: () {
              setState(() {
                _selectedMonth = month;
              });
            },
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF315C81)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                _getMonthName(month),
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF8291A0),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth = _getDaysInMonth(_selectedYear, _selectedMonth);
    final firstDayWeekday = _getWeekday(_selectedYear, _selectedMonth, 1);
    final adjustedFirstDay = (firstDayWeekday - 1) % 7;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        childAspectRatio: 1,
      ),
      itemCount: daysInMonth + adjustedFirstDay,
      itemBuilder: (context, index) {
        if (index < adjustedFirstDay) {
          return const SizedBox.shrink();
        }

        final dayIndex = index - adjustedFirstDay + 1;
        final isCurrentMonth = _selectedMonth == DateTime.now().month;
        final isToday = dayIndex == DateTime.now().day &&
            isCurrentMonth &&
            _selectedYear == DateTime.now().year;

        final expiringProducts = _productsWithExpirations
            .where((product) {
              final exp = product.expirationDate;
              return exp.day == dayIndex &&
                  exp.month == _selectedMonth &&
                  exp.year == _selectedYear;
            })
            .toList();

        return _CalendarDay(
          day: dayIndex,
          isToday: isToday,
          isExpiring: expiringProducts.isNotEmpty,
          productCount: expiringProducts.length,
          onTap: () => _onDayTap(dayIndex, expiringProducts),
        );
      },
    );
  }

  int _getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  int _getWeekday(int year, int month, int day) {
    return DateTime(year, month, day).weekday;
  }

  String _getMonthName(int month) {
    const arabicMonthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return arabicMonthNames[month - 1];
  }

  void _onDayTap(int day, List<Product> expiringProducts) {
    if (expiringProducts.isNotEmpty) {
      context.go('/products');
    }
  }

  void _previousMonth() {
    setState(() {
      if (_selectedMonth == 1) {
        _selectedMonth = 12;
        _selectedYear--;
      } else {
        _selectedMonth--;
      }
    });
  }

  void _nextMonth() {
    setState(() {
      if (_selectedMonth == 12) {
        _selectedMonth = 1;
        _selectedYear++;
      } else {
        _selectedMonth++;
      }
    });
  }

  Widget _buildSelectedDateInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDEE4E8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Expiring This Month',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF8291A0),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_productsWithExpirations.length} products',
            style: AppTypography.bodyMedium.copyWith(
              color: const Color(0xFF182635),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _productsWithExpirations
                  .take(3)
                  .map((product) => _buildExpiringProductTile(product))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpiringProductTile(Product product) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      width: 100,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5F0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.calendar_today,
            size: 16,
            color: Color(0xFF42A886),
          ),
          const SizedBox(height: 4),
          Text(
            product.productName,
            style: AppTypography.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '${product.remainingDays}d',
            style: AppTypography.bodySmall.copyWith(
              color: const Color(0xFF42A886),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarDay extends StatelessWidget {
  final int day;
  final bool isToday;
  final bool isExpiring;
  final int productCount;
  final VoidCallback onTap;

  const _CalendarDay({
    required this.day,
    required this.isToday,
    required this.isExpiring,
    required this.productCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: isToday
              ? const Color(0xFF315C81).withValues(alpha: 0.1)
              : isExpiring
                  ? const Color(0xFFE8A64D).withValues(alpha: 0.1)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isToday
              ? Border.all(color: const Color(0xFF315C81))
              : isExpiring
                  ? Border.all(color: const Color(0xFFE8A64D))
                  : null,
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$day',
              style: TextStyle(
                fontWeight: isToday || isExpiring ? FontWeight.bold : FontWeight.normal,
                color: isToday
                    ? const Color(0xFF315C81)
                    : isExpiring
                        ? const Color(0xFFE8A64D)
                        : const Color(0xFF182635),
                fontSize: 13,
              ),
            ),
            if (isExpiring)
              Container(
                margin: const EdgeInsets.only(top: 2),
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8A64D),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
