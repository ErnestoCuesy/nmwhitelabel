import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nmwhitelabel/app/models/restaurant.dart';

class RestaurantListTile extends StatelessWidget {
  final Restaurant? restaurant;
  final bool? restaurantFound;

  const RestaurantListTile({Key? key, this.restaurant, this.restaurantFound})
      : super(key: key);

  Widget _buildTitle(BuildContext context) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width - 150,
                  child: Text(
                    restaurant!.name!,
                    style: Theme.of(context).textTheme.headline5,
                  ),
                ),
                Container(
                  width: 30.00,
                    child: Icon(
                      Icons.arrow_forward,
                    ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 8.0,
          ),
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Icon(
                  Icons.location_on,
                  size: 20.0,
                ),
              ),
              Text(
                '${restaurant!.address1}, ${restaurant!.address2}',
              ),
            ],
          ),
          if (restaurant!.address3 != '')
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Icon(
                  Icons.arrow_right,
                  size: 20.0,
                ),
              ),
              Text(
                '${restaurant!.address3}, ${restaurant!.address4}',
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Icon(
                  Icons.restaurant,
                  size: 20.0,
                ),
              ),
              Text(
                restaurant!.typeOfFood!,
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Icon(
                  Icons.info_outline,
                  size: 20.0,
                ),
              ),
              Text(
                restaurant!.notes!.substring(0, restaurant!.notes!.length > 30 ? 30 : restaurant!.notes!.length),
              ),
            ],
          ),
        ],
      );
  }

  Widget _buildSubtitle(BuildContext context) {
    final currencySymbol = NumberFormat.simpleCurrency(locale: "en_ZA");
    final MaterialLocalizations localizations =
        MaterialLocalizations.of(context);
    final String hoursFrom =
        localizations.formatTimeOfDay(restaurant!.workingHoursFrom!);
    final String hoursTo =
        localizations.formatTimeOfDay(restaurant!.workingHoursTo!);
    var status = 'Open';
    if (!restaurant!.isOpen) {
      status = 'Closed';
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Icon(
                Icons.access_time,
                size: 20.0,
              ),
            ),
            Text(
              '$hoursFrom  - $hoursTo ($status)',
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Icon(
                Icons.call,
                size: 20.0,
              ),
            ),
            Text(
              restaurant!.telephoneNumber!,
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                'Payment options: ',
              ),
            ),
            if (restaurant!.acceptCash!)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(currencySymbol.currencySymbol),
              ),
            if (restaurant!.acceptCard!)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.credit_card,
                  size: 14.0,
                ),
              ),
            if (restaurant!.acceptOther!)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.flash_on,
                  size: 14.0,
                ),
              ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
      return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildTitle(context),
            _buildSubtitle(context),
          ]
      );
  }
}
