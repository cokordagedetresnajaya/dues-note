import 'package:flutter/material.dart';
import '../../configs/colors.dart';
import '../utils/vertical_space_10.dart';
import '../utils/vertical_space_20.dart';

class AddMemberBottomSheetForm extends StatelessWidget {
  final Key? formKey;
  final String? Function(String?)? validator;
  final void Function(String?)? onSavedFn;
  final void Function()? addMemberFn;

  AddMemberBottomSheetForm({
    this.formKey,
    this.validator,
    this.onSavedFn,
    this.addMemberFn,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: FractionallySizedBox(
        heightFactor: 0.4,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 40,
                  height: 6,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                    color: AppColors.primary,
                  ),
                ),
              ),
              const VerticalSpace20(),
              Text(
                'Member Name',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const VerticalSpace10(),
              TextFormField(
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(16),
                  hintText: 'Enter member name',
                  hintStyle: Theme.of(context).textTheme.labelSmall,
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                    borderSide: BorderSide(
                      color: AppColors.gray,
                      style: BorderStyle.solid,
                      width: 0.5,
                    ),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                    borderSide: BorderSide(
                      color: AppColors.gray,
                      style: BorderStyle.solid,
                      width: 0.5,
                    ),
                  ),
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: AppColors.gray,
                      style: BorderStyle.solid,
                      width: 1,
                    ),
                  ),
                ),
                validator: validator,
                onSaved: onSavedFn,
              ),
              const VerticalSpace20(),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(bottom: 16),
                child: ElevatedButton(
                  child: const Text(
                    'ADD MEMBER',
                    style: TextStyle(
                      color: AppColors.background,
                    ),
                  ),
                  onPressed: addMemberFn,
                  style: ButtonStyle(
                    padding: MaterialStateProperty.all(
                      const EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 16,
                      ),
                    ),
                    backgroundColor: MaterialStateProperty.all(
                      AppColors.primary,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
