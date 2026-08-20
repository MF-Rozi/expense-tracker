import 'package:expense_tracker/features/category/domain/entities/category.dart';
import 'package:expense_tracker/features/category/presentation/blocs/category_cubit.dart';
import 'package:expense_tracker/features/category/presentation/blocs/category_state.dart';
import 'package:expense_tracker/features/category/presentation/widgets/envelope_creation_form.dart';
import 'package:expense_tracker/features/category/presentation/widgets/hierarchy_insight_card.dart';
import 'package:expense_tracker/shared/domain/entities/value_objects.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryFormPage extends StatefulWidget {
  const CategoryFormPage({
    this.activeParentUuid,
    this.categoryToEdit,
    super.key,
  });

  final String? activeParentUuid;
  final Category? categoryToEdit;

  @override
  State<CategoryFormPage> createState() => _CategoryFormPageState();
}

class _CategoryFormPageState extends State<CategoryFormPage> {
  late TextEditingController _nameController;
  late TextEditingController _budgetController;
  Category? _selectedPillar;
  BehavioralModifier _selectedModifier = BehavioralModifier.active;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.categoryToEdit?.name.getOrCrash() ?? '',
    );
    _budgetController = TextEditingController(
      text: widget.categoryToEdit?.expectedMonthlyBudget != null &&
              (widget.categoryToEdit?.expectedMonthlyBudget ?? 0) > 0
          ? widget.categoryToEdit!.expectedMonthlyBudget.toStringAsFixed(2)
          : '',
    );
    if (widget.categoryToEdit != null) {
      _selectedModifier = widget.categoryToEdit!.behavioralModifier;
    }

    _nameController.addListener(_onFormInputChanged);
    _budgetController.addListener(_onFormInputChanged);
  }

  void _onFormInputChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _nameController.removeListener(_onFormInputChanged);
    _budgetController.removeListener(_onFormInputChanged);
    _nameController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Category? _resolveParentCategory(CategoryState state) {
    if (widget.activeParentUuid != null) {
      return state.allCategories.cast<Category?>().firstWhere(
            (c) => c?.uuid.getOrCrash() == widget.activeParentUuid,
            orElse: () => null,
          );
    }
    return null;
  }

  Category? _resolvePillarCategory(
    CategoryState state,
    Category? activeParent,
  ) {
    if (_selectedPillar != null) {
      return _selectedPillar;
    }

    if (activeParent != null) {
      if (activeParent.isRoot) {
        return activeParent;
      } else if (activeParent.parentId != null) {
        return state.allCategories.cast<Category?>().firstWhere(
              (c) => c?.uuid == activeParent.parentId,
              orElse: () => null,
            );
      }
    }

    return state.activePillars.isNotEmpty ? state.activePillars.first : null;
  }

  Category? _resolveSubParentCategory(Category? activeParent) {
    if (activeParent != null && !activeParent.isRoot) {
      return activeParent;
    }
    return null;
  }

  void _onSave(CategoryState state) {
    final nameText = _nameController.text.trim();
    if (nameText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an envelope name')),
      );
      return;
    }

    final activeParent = _resolveParentCategory(state);
    final effectivePillar = _resolvePillarCategory(state, activeParent);
    final effectiveSubParent = _resolveSubParentCategory(activeParent);

    // Parent ID resolution
    final parentId = effectiveSubParent?.uuid ??
        effectivePillar?.uuid ??
        (widget.activeParentUuid != null
            ? UniqueId(widget.activeParentUuid!)
            : null);

    final parsedBudget = double.tryParse(_budgetController.text) ?? 0.0;

    final category = Category(
      uuid: widget.categoryToEdit?.uuid ?? UniqueId.generate(),
      name: StringSingleLine(nameText),
      type: state.selectedType,
      parentId: parentId,
      expectedMonthlyBudget: parsedBudget,
      behavioralModifier: _selectedModifier,
      isSynced: false,
      updatedAt: DateTime.now(),
    );

    setState(() {
      _isSaving = true;
    });
    context.read<CategoryCubit>().saveCategory(category);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // surface
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF00113A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.categoryToEdit == null ? 'New Envelope' : 'Edit Envelope',
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF00113A),
          ),
        ),
      ),
      body: BlocListener<CategoryCubit, CategoryState>(
        listener: (context, state) {
          if (!_isSaving) return;
          if (state.error != null && state.error!.isNotEmpty) {
            setState(() {
              _isSaving = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to save envelope: ${state.error}'),
              ),
            );
          } else if (!state.isLoading && state.error == null) {
            setState(() {
              _isSaving = false;
            });
            Navigator.of(context).pop();
          }
        },
        child: BlocBuilder<CategoryCubit, CategoryState>(
          builder: (context, state) {
            final activeParent = _resolveParentCategory(state);
            final pillar = _resolvePillarCategory(state, activeParent);
            final subParent = _resolveSubParentCategory(activeParent);
            final parsedBudget = double.tryParse(_budgetController.text) ?? 0.0;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    'Record Entry'.toUpperCase(),
                    style: GoogleFonts.manrope(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF00113A),
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Configure your sovereign ledger architecture.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF444650),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Main Form Component
                  EnvelopeCreationForm(
                    selectedType: state.selectedType,
                    availablePillars: state.activePillars,
                    selectedPillar: pillar,
                    selectedModifier: _selectedModifier,
                    nameController: _nameController,
                    budgetController: _budgetController,
                    onTypeChanged: (type) {
                      context.read<CategoryCubit>().setCategoryType(type);
                      setState(() {
                        _selectedPillar = null;
                      });
                    },
                    onPillarChanged: (selectedPillar) {
                      setState(() {
                        _selectedPillar = selectedPillar;
                      });
                    },
                    onModifierChanged: (modifier) {
                      setState(() {
                        _selectedModifier = modifier;
                      });
                    },
                  ),

                  const SizedBox(height: 32),

                  // Dynamic Hierarchy Insight Card
                  HierarchyInsightCard(
                    envelopeName: _nameController.text.trim(),
                    pillar: pillar,
                    subParent: subParent,
                    totalBudget: state.totalBudget,
                    envelopeBudget: parsedBudget,
                  ),

                  const SizedBox(height: 48),

                  // Action Buttons
                  ElevatedButton(
                    onPressed: state.isLoading || _isSaving
                        ? null
                        : () => _onSave(state),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00113A),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 64),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      elevation: 8,
                      shadowColor:
                          const Color(0xFF00113A).withValues(alpha: 0.4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_outline),
                        const SizedBox(width: 8),
                        Text(
                          'Save Configuration',
                          style: GoogleFonts.manrope(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    child: Text(
                      'Discard Changes',
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF444650),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
