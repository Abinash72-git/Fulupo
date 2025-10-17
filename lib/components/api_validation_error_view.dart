
import 'package:flutter/material.dart';
import 'package:fulupo/model/api_validation_model.dart';
import 'package:fulupo/util/extension.dart';


class ApiValidationErrorView extends StatelessWidget {
  final ApiValidationModel data;
  ApiValidationErrorView({required this.data});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          data.message!,
          style: context.textTheme.bodySmall!
              .copyWith(color: context.customColorScheme.redColor),
          textAlign: TextAlign.left,
        ),
        const SizedBox(
          height: 10,
        ),
        ListView.builder(
            primary: true,
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: data.validationErrors.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  "${data.validationErrors[index].field!} : ${data.validationErrors[index].message!}",
                  style: context.textTheme.bodySmall!
                      .copyWith(color: context.customColorScheme.redColor),
                  textAlign: TextAlign.left,
                ),
              );
            }),
      ],
    );
  }
}
