import 'package:expense_tracker/features/category/domain/entities/category.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// The complete creation form for a new envelope.
///
/// Contains:
///   - Envelope nature segmented toggle (Expense / Income)
///   - Pillar picker (Level 1 cards: Essential / Lifestyle / Growth or income
///     equivalents)
///   - Name text field
///   - Large centered budget input
///   - Behavioral modifier pills (Active / Passive / Recurring)
///
/// This is a *display-only* widget; all state is managed by the caller via
/// callbacks, so it remains independently testable.
///
/// Mirrors the form layout in the HTML mockup (category-new-design.html,
/// lines 148–266 & 532–650).
class EnvelopeCreationForm extends StatelessWidget {
  const EnvelopeCreationForm({
    required this.selectedType,
    required this.availablePillars,
    required this.selectedPillar,
    required this.selectedModifier,
    required this.nameController,
    required this.budgetController,
    required this.onTypeChanged,
    required this.onPillarChanged,
    required this.onModifierChanged,
    super.key,
  });

  /// Expense or Income toggle.
  final CategoryType selectedType;

  /// The available Level 1 pillar categories for the selected type.
  final List<Category> availablePillars;

  /// The currently selected pillar.
  final Category? selectedPillar;

  /// The currently selected behavioral modifier.
  final BehavioralModifier selectedModifier;

  /// Controller for the envelope name field.
  final TextEditingController nameController;

  /// Controller for the budget field.
  final TextEditingController budgetController;

  final ValueChanged<CategoryType> onTypeChanged;
  final ValueChanged<Category?> onPillarChanged;
  final ValueChanged<BehavioralModifier> onModifierChanged;

  // Design tokens
  static const _primary = Color(0xFF00113A);
  static const _primaryContainer = Color(0xFF002366);
  static const _onPrimaryContainer = Color(0xFF758DD5);
  static const _surfaceContainerLow = Color(0xFFF3F4F5);
  static const _surfaceContainerLowest = Color(0xFFFFFFFF);
  static const _onSurface = Color(0xFF191C1D);
  static const _onSurfaceVariant = Color(0xFF444650);
  static const _outline = Color(0xFF757682);
  static const _outlineVariant = Color(0xFFC5C6D2);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildNatureToggle(),
        const SizedBox(height: 32),
        _buildPillarPicker(),
        const SizedBox(height: 32),
        _buildNameField(),
        const SizedBox(height: 32),
        _buildBudgetInput(),
        const SizedBox(height: 24),
        _buildModifierToggles(),
      ],
    );
  }

  // ─────────────────────────────── Nature Toggle ────────────────────────────

  Widget _buildNatureToggle() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: _surfaceContainerLow,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        children: [
          _buildToggleButton(
            label: 'Expense',
            isActive: selectedType == CategoryType.expense,
            onTap: () => onTypeChanged(CategoryType.expense),
          ),
          const SizedBox(width: 4),
          _buildToggleButton(
            label: 'Income',
            isActive: selectedType == CategoryType.income,
            onTap: () => onTypeChanged(CategoryType.income),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: isActive
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_primary, _primaryContainer],
                  )
                : null,
            borderRadius: BorderRadius.circular(99),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isActive ? Colors.white : _onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────── Pillar Picker ───────────────────────────

  Widget _buildPillarPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Envelope Type'),
        const SizedBox(height: 8),
        if (availablePillars.isEmpty)
          _buildEmptyPillarsPlaceholder()
        else
          _buildPillarGrid(),
      ],
    );
  }

  Widget _buildEmptyPillarsPlaceholder() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: _surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          'No pillars available',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: _outline,
          ),
        ),
      ),
    );
  }

  Widget _buildPillarGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: availablePillars.length,
      itemBuilder: (context, index) {
        final pillar = availablePillars[index];
        final isSelected =
            selectedPillar?.uuid == pillar.uuid;
        return _PillarCard(
          pillar: pillar,
          isSelected: isSelected,
          onTap: () => onPillarChanged(isSelected ? null : pillar),
        );
      },
    );
  }

  // ───────────────────────────────── Name Field ─────────────────────────────

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Category Name'),
        const SizedBox(height: 16),
        TextField(
          controller: nameController,
          style: GoogleFonts.manrope(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: _onSurface,
          ),
          decoration: InputDecoration(
            hintText: 'e.g. Artisanal Coffee',
            hintStyle: GoogleFonts.manrope(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: _outlineVariant,
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: _outlineVariant, width: 2),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: _primary, width: 2),
            ),
            filled: false,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
          textCapitalization: TextCapitalization.words,
        ),
      ],
    );
  }

  // ──────────────────────────────── Budget Input ────────────────────────────

  Widget _buildBudgetInput() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionLabel('Expected Monthly Budget'),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                r'$',
                style: GoogleFonts.manrope(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: _outlineVariant,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: budgetController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,2}'),
                    ),
                  ],
                  style: GoogleFonts.manrope(
                    fontSize: 44,
                    fontWeight: FontWeight.w800,
                    color: _primary,
                  ),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    hintStyle: GoogleFonts.manrope(
                      fontSize: 44,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFE7E8E9),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFEDEEEF), thickness: 1),
          const SizedBox(height: 12),
          Text(
            'This figure serves as your baseline for liquidity projections.',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: _outline,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────── Modifier Toggles ────────────────────────────

  Widget _buildModifierToggles() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Behavioral Configuration'),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildModifierPill(
              label: 'Active',
              icon: Icons.bolt_outlined,
              modifier: BehavioralModifier.active,
            ),
            const SizedBox(width: 12),
            _buildModifierPill(
              label: 'Passive',
              icon: Icons.waves_outlined,
              modifier: BehavioralModifier.passive,
            ),
            const SizedBox(width: 12),
            _buildModifierPill(
              label: 'Recurring',
              icon: Icons.autorenew_outlined,
              modifier: BehavioralModifier.recurring,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModifierPill({
    required String label,
    required IconData icon,
    required BehavioralModifier modifier,
  }) {
    final isSelected = selectedModifier == modifier;
    return Expanded(
      child: GestureDetector(
        onTap: () => onModifierChanged(modifier),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? _onPrimaryContainer.withValues(alpha: 0.15)
                : _surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(
                    color: _primary.withValues(alpha: 0.15),
                    width: 2,
                  )
                : null,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 22,
                color: isSelected ? _primary : _onSurfaceVariant,
              ),
              const SizedBox(height: 6),
              Text(
                label.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                  color: isSelected ? _primary : _onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────── Helper ───────────────────────────────────

  Widget _buildSectionLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 2,
        color: _outline,
      ),
    );
  }
}

// ──────────────────────────────── Pillar Card ─────────────────────────────

class _PillarCard extends StatelessWidget {
  const _PillarCard({
    required this.pillar,
    required this.isSelected,
    required this.onTap,
  });

  final Category pillar;
  final bool isSelected;
  final VoidCallback onTap;

  static const _primary = Color(0xFF00113A);
  static const _surfaceContainerLow = Color(0xFFF3F4F5);
  static const _onSurfaceVariant = Color(0xFF444650);

  IconData _iconForPillar(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('essential') || lower.contains('need')) {
      return Icons.shield_outlined;
    } else if (lower.contains('lifestyle') || lower.contains('life')) {
      return Icons.auto_awesome_outlined;
    } else if (lower.contains('growth') || lower.contains('invest')) {
      return Icons.trending_up;
    } else if (lower.contains('revenue') || lower.contains('primary')) {
      return Icons.account_balance_outlined;
    } else if (lower.contains('secondary') || lower.contains('income')) {
      return Icons.show_chart;
    } else if (lower.contains('portfolio')) {
      return Icons.trending_up;
    }
    return Icons.folder_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final name = pillar.name.getOrCrash();
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF00113A), Color(0xFF002366)],
                )
              : null,
          color: isSelected ? null : _surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: _primary.withValues(alpha: 0.1), width: 2)
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: _primary.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _iconForPillar(name),
                  size: 22,
                  color: isSelected ? Colors.white : _onSurfaceVariant,
                ),
                const SizedBox(height: 6),
                Text(
                  name.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: isSelected ? Colors.white : _onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            if (isSelected)
              Positioned(
                top: 0,
                right: 0,
                child: Icon(
                  Icons.check_circle,
                  size: 14,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
