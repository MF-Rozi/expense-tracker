import 'package:expense_tracker/features/category/domain/entities/category.dart';
import 'package:expense_tracker/features/category/presentation/blocs/category_cubit.dart';
import 'package:expense_tracker/features/category/presentation/blocs/category_state.dart';
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
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.categoryToEdit?.name.getOrCrash() ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_formKey.currentState?.validate() ?? false) {
      final category = Category(
        uuid: widget.categoryToEdit?.uuid ?? UniqueId.generate(),
        name: StringSingleLine(_nameController.text),
        isSynced: false,
        updatedAt: DateTime.now(),
        parentUuid: widget.activeParentUuid != null
            ? UniqueId(widget.activeParentUuid!)
            : widget.categoryToEdit?.parentUuid,
      );

      setState(() {
        _isSaving = true;
      });
      context.read<CategoryCubit>().saveCategory(category);
    }
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
          widget.categoryToEdit == null ? 'New Category' : 'Edit Category',
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
                content: Text('Failed to save category: ${state.error}'),
              ),
            );
          } else if (!state.isLoading && state.error == null) {
            setState(() {
              _isSaving = false;
            });
            // Success! Pop ONLY after the async operation completes successfully
            Navigator.of(context).pop();
          }
        },
        child: BlocBuilder<CategoryCubit, CategoryState>(
          builder: (context, state) {
            final parentCategory = widget.activeParentUuid != null
                ? state.allCategories.firstWhere(
                    (c) => c.uuid.getOrCrash() == widget.activeParentUuid,
                  )
                : null;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
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
                        color: const Color(0xFF444650), // on-surface-variant
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Category Name Input
                    _BentoInputCell(
                      label: 'Category Name',
                      child: TextFormField(
                        controller: _nameController,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF191C1D), // on-surface
                        ),
                        decoration: const InputDecoration(
                          hintText: 'e.g., Artisan Coffee',
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a name';
                          }
                          if (value.contains('\n')) {
                            return 'Name must be a single line';
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Parent Category (Read-only if pre-selected)
                    _BentoInputCell(
                      label: 'Parent Architecture',
                      isReadOnly: widget.activeParentUuid != null,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              parentCategory?.name.getOrCrash() ?? 'Root Level',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: widget.activeParentUuid != null
                                    ? const Color(0xFF757682)
                                    : const Color(0xFF191C1D),
                              ),
                            ),
                          ),
                          if (widget.activeParentUuid == null)
                            const Icon(
                              Icons.expand_more,
                              color: Color(0xFF757682),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Action Buttons
                    ElevatedButton(
                      onPressed: state.isLoading || _isSaving ? null : _onSave,
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
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BentoInputCell extends StatelessWidget {
  const _BentoInputCell({
    required this.label,
    required this.child,
    this.isReadOnly = false,
  });

  final String label;
  final Widget child;
  final bool isReadOnly;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: const Color(0xFF00113A),
            ),
          ),
        ),
        Focus(
          child: Builder(
            builder: (context) {
              final isFocused = Focus.of(context).hasFocus;
              return Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                decoration: BoxDecoration(
                  color: isReadOnly
                      ? const Color(0xFFEDEEEF) // surface-container
                      : const Color(0xFFF3F4F5), // surface-container-low
                  border: Border(
                    bottom: BorderSide(
                      color: isFocused
                          ? const Color(0xFF00113A)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: child,
              );
            },
          ),
        ),
      ],
    );
  }
}
