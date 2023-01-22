import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/organization_fee.dart';
import '../../configs/colors.dart';
import '../../screens/organization_fee/organization_fee_detail_screen.dart';
import '../utils/vertical_space_20.dart';
import '../utils/vertical_space_10.dart';

class OrganizationFeeListItem extends StatefulWidget {
  final OrganizationFee organizationFee;
  final Function isDeleteMode;
  final Function setDeleteMode;
  final Function setSelectedOrganizationFee;
  final Function clearSelectedOrganizationFee;
  final Function getSelectedOrganizationFee;

  OrganizationFeeListItem(
    this.organizationFee,
    this.isDeleteMode,
    this.setDeleteMode,
    this.setSelectedOrganizationFee,
    this.clearSelectedOrganizationFee,
    this.getSelectedOrganizationFee,
  );

  @override
  State<OrganizationFeeListItem> createState() =>
      _OrganizationFeeListItemState();
}

class _OrganizationFeeListItemState extends State<OrganizationFeeListItem> {
  bool _isSelected = false;
  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: widget.getSelectedOrganizationFee() != null &&
              widget.getSelectedOrganizationFee().id ==
                  widget.organizationFee.id
          ? () {
              widget.setDeleteMode(false);
              widget.clearSelectedOrganizationFee();
            }
          : () {
              Navigator.of(context)
                  .pushNamed(
                OrganizationFeeDetailScreen.routeName,
                arguments: widget.organizationFee.id,
              )
                  .then(
                (_) {
                  widget.setDeleteMode(false);
                  widget.clearSelectedOrganizationFee();
                },
              );
            },
      onLongPress: () {
        if (!widget.isDeleteMode()) {
          widget.setDeleteMode(true);
          widget.setSelectedOrganizationFee(widget.organizationFee);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 0,
        ),
        width: double.infinity,
        decoration: BoxDecoration(
          border: widget.getSelectedOrganizationFee() != null &&
                  widget.getSelectedOrganizationFee().id ==
                      widget.organizationFee.id
              ? Border.all(
                  color: AppColors.secondaryLight,
                  width: 3.0,
                )
              : Border.all(
                  style: BorderStyle.none,
                ),
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: AppColors.gray,
              blurRadius: 2, // soften the shadow
              spreadRadius: 0, //extend the shadow
              offset: Offset(
                0, // Move to right 10  horizontally
                3, // Move to bottom 10 Vertically
              ),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: widget.organizationFee.isActive
                  ? [
                      Flexible(
                        child: Text(
                          widget.organizationFee.title,
                          style: const TextStyle(
                            color: AppColors.background,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.2,
                        child: const Text(
                          'Active',
                          style: TextStyle(
                            color: AppColors.lightGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.end,
                        ),
                      )
                    ]
                  : [
                      Flexible(
                        child: Text(
                          widget.organizationFee.title,
                          style: const TextStyle(
                            color: AppColors.background,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Text(
                        'Unactive',
                        style: TextStyle(
                          color: AppColors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      )
                    ],
            ),
            Text(
              '${DateFormat.d().format(widget.organizationFee.startDate)} ${DateFormat.MMM().format(widget.organizationFee.startDate)} ${DateFormat.y().format(widget.organizationFee.startDate)} - ${DateFormat.d().format(widget.organizationFee.endDate)} ${DateFormat.MMM().format(widget.organizationFee.endDate)} ${DateFormat.y().format(widget.organizationFee.endDate)}',
              style: const TextStyle(
                color: AppColors.gray,
                fontSize: 14,
              ),
            ),
            const VerticalSpace20(),
            Container(
              width: double.infinity,
              child: Stack(
                children: [
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: screenWidth - 64,
                    ),
                    height: 5,
                    color: AppColors.lightGray,
                  ),
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: screenWidth - 64,
                    ),
                    width: (screenWidth - 64) *
                        (widget.organizationFee.numberOfPaidMembers /
                            widget.organizationFee.numberOfMembers),
                    height: 5,
                    color: AppColors.secondaryLight,
                  ),
                ],
              ),
            ),
            const VerticalSpace10(),
            Text(
              '${widget.organizationFee.numberOfPaidMembers} from ${widget.organizationFee.numberOfMembers} member already paid',
              style: const TextStyle(
                color: AppColors.gray,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
