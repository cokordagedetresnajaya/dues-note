import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/organization_fee.dart';
import '../screens/organization_fee/organization_fee_detail_screen.dart';
import './utils/vertical_space_20.dart';
import './utils/vertical_space_10.dart';

class CashflowActiveDuesItem extends StatefulWidget {
  final OrganizationFee organizationFee;
  CashflowActiveDuesItem(this.organizationFee);

  @override
  State<CashflowActiveDuesItem> createState() => _CashflowActiveDuesItemState();
}

class _CashflowActiveDuesItemState extends State<CashflowActiveDuesItem> {
  bool _isSelected = false;
  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          OrganizationFeeDetailScreen.routeName,
          arguments: widget.organizationFee.id,
        );
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
          border: _isSelected
              ? Border.all(
                  color: Theme.of(context).primaryColorLight,
                  width: 3.0,
                )
              : Border.all(
                  style: BorderStyle.none,
                ),
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(181, 181, 181, 1),
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
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Text(
                        'Active',
                        style: TextStyle(
                          color: Color.fromRGBO(39, 207, 147, 1),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      )
                    ]
                  : [
                      Flexible(
                        child: Text(
                          widget.organizationFee.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Text(
                        'Unactive',
                        style: TextStyle(
                          color: Color.fromRGBO(207, 55, 39, 1),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      )
                    ],
            ),
            Text(
              '${DateFormat.d().format(widget.organizationFee.startDate)} ${DateFormat.MMM().format(widget.organizationFee.startDate)} ${DateFormat.y().format(widget.organizationFee.startDate)} - ${DateFormat.d().format(widget.organizationFee.endDate)} ${DateFormat.MMM().format(widget.organizationFee.endDate)} ${DateFormat.y().format(widget.organizationFee.endDate)}',
              style: const TextStyle(
                color: Color.fromRGBO(
                  181,
                  181,
                  181,
                  1,
                ),
                fontSize: 14,
              ),
            ),
            const VerticalSpace20(),
            Container(
              width: double.infinity,
              child: Stack(
                children: [
                  Container(
                    constraints: BoxConstraints(maxWidth: screenWidth - 64),
                    height: 5,
                    color: const Color.fromRGBO(217, 217, 217, 1),
                  ),
                  Container(
                    constraints: BoxConstraints(maxWidth: screenWidth - 64),
                    width: (screenWidth - 64) *
                        (widget.organizationFee.numberOfPaidMembers /
                            widget.organizationFee.numberOfMembers),
                    height: 5,
                    color: Theme.of(context).primaryColorLight,
                  ),
                ],
              ),
            ),
            const VerticalSpace10(),
            Text(
              '${widget.organizationFee.numberOfPaidMembers} from ${widget.organizationFee.numberOfMembers} member already paid',
              style: const TextStyle(
                color: Color.fromRGBO(
                  181,
                  181,
                  181,
                  1,
                ),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
