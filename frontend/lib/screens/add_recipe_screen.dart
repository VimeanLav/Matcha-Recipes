import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/recipe_model.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../services/supabase_recipe_service.dart';

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _titleController = TextEditingController();
  final _timeController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _ingredientsController = TextEditingController();

  final _authService = AuthService();
  final _recipeService = SupabaseRecipeService();
  final _storageService = StorageService();
  final _picker = ImagePicker();

  RecipeCategory? _category;
  Uint8List? _imageBytes;
  String _imageContentType = 'image/jpeg';
  bool _submitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _timeController.dispose();
    _caloriesController.dispose();
    _ingredientsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;

    final bytes = await file.readAsBytes();
    if (!mounted) return;

    setState(() {
      _imageBytes = bytes;
      _imageContentType = file.mimeType ?? 'image/jpeg';
    });
  }

  String? _validate() {
    if (_imageBytes == null) return 'Please add a photo.';
    if (_titleController.text.trim().isEmpty) return 'Enter title.';
    if (_category == null) return 'Choose category.';
    if (int.tryParse(_timeController.text.trim()) == null) {
      return 'Enter time in minutes.';
    }
    if (int.tryParse(_caloriesController.text.trim()) == null) {
      return 'Enter calories as a number.';
    }
    if (_ingredientsController.text.trim().isEmpty) return 'Enter ingredients.';

    return null;
  }

  Future<void> _submit() async {
    if (_submitting) return;

    final error = _validate();
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    final user = _authService.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in first.')),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      final imageUrl = await _storageService.uploadRecipeImage(
        uid: user.uid,
        bytes: _imageBytes!,
        contentType: _imageContentType,
      );

      final recipe = RecipeModel(
        id: '',
        title: _titleController.text.trim(),
        category: _category!,
        timeMinutes: int.parse(_timeController.text.trim()),
        calories: int.parse(_caloriesController.text.trim()),
        ingredients: _ingredientsController.text.trim(),
        imageUrl: imageUrl,
        createdBy: user.uid,
      );

      await _recipeService.createRecipe(recipe);

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'New recipe',
                      style: theme.textTheme.displaySmall,
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(22),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 170,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5EED8),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: const Color(0xFFAFC6A2),
                      width: 1.5,
                    ),
                  ),
                  child: _imageBytes == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.photo_camera_outlined,
                              color: colorScheme.onSurfaceVariant,
                              size: 28,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Add a photo',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'JPG or PNG - up to 5MB',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: Image.memory(
                            _imageBytes!,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
              _LabeledField(
                label: 'Recipe title',
                controller: _titleController,
                hintText: 'Matcha latte',
              ),
              const SizedBox(height: 18),
              Text(
                'Category',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _CategoryPill(
                    label: 'Drinks',
                    selected: _category == RecipeCategory.drinks,
                    onTap: () => setState(() => _category = RecipeCategory.drinks),
                  ),
                  const SizedBox(width: 12),
                  _CategoryPill(
                    label: 'Desserts',
                    selected: _category == RecipeCategory.desserts,
                    onTap: () => setState(() => _category = RecipeCategory.desserts),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _LabeledField(
                      label: 'Time',
                      controller: _timeController,
                      hintText: '10 min',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _LabeledField(
                      label: 'Calories',
                      controller: _caloriesController,
                      hintText: '140',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _LabeledField(
                label: 'Ingredients',
                controller: _ingredientsController,
                hintText: '2 tsp matcha powder\n240 ml oat milk\n1 tsp honey',
                maxLines: 5,
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    backgroundColor: const Color(0xFF557A45),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(_submitting ? 'Uploading...' : 'Upload recipe'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.controller,
    this.hintText,
    this.maxLines = 1,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final String? hintText;
  final int maxLines;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: const Color(0xFFF1F5E7),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF557A45) : const Color(0xFFF1F5E7),
            borderRadius: BorderRadius.circular(24),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: selected ? Colors.white : const Color(0xFF263025),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
