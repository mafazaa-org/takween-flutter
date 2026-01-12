import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../config/app_colors.dart';

class RoleSelector extends StatelessWidget {
  final String formControlName;

  const RoleSelector({
    super.key,
    required this.formControlName,
  });

  @override
  Widget build(BuildContext context) {
    return ReactiveFormConsumer(
      builder: (context, form, child) {
        final isParent = form.control(formControlName).value == 'parent';

        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.lightGray),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    form.control(formControlName).value = 'parent';
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: isParent ? AppColors.green : AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'والد/والدة',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isParent ? AppColors.white : AppColors.charcoal,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    form.control(formControlName).value = 'admin';
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: !isParent ? AppColors.green : AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'مدير',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: !isParent ? AppColors.white : AppColors.charcoal,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

