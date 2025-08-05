import 'package:flutter/material.dart';
import 'package:myapp/l10n/app_localizations.dart';
import 'package:myapp/screens/home_page.dart';
import 'package:myapp/models/education_category.dart';
import 'package:myapp/services/supabase_service.dart';

class EducationCategoryScreen extends StatefulWidget {
  const EducationCategoryScreen({Key? key}) : super(key: key);

  @override
  _EducationCategoryScreenState createState() => _EducationCategoryScreenState();
}

class _EducationCategoryScreenState extends State<EducationCategoryScreen> {
  late Future<List<EducationCategory>> _educationCategoriesFuture;

  @override
  void initState() {
    super.initState();
    _educationCategoriesFuture = _fetchEducationCategories();
  }

  Future<List<EducationCategory>> _fetchEducationCategories() async {
    final supabaseService = SupabaseService();
    return supabaseService.getEducationCategories();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Educational Categories'),
      ),
      body: FutureBuilder<List<EducationCategory>>(
        future: _educationCategoriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No categories available.'));
          } else {
            return GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 1.0,
              ),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final category = snapshot.data![index];
                return _buildFeatureItem(
                  context,
                  category.categoryName,
                  category.categoryImage,
                  null,
                );
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context,
    String title,
    String imagePath,
    Widget? destinationPage,
  ) {
    final localizations = AppLocalizations.of(context)!;
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          if (destinationPage != null) {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => destinationPage),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(localizations.notYetImplemented(title))),
            );
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: SizedBox(
                width: double.infinity,
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 50,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 8.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[200],
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 16.0,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}