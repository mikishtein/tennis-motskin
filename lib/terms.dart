import 'package:flutter/material.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('תקנון החזרים וביטולים')),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            '''
תקנון החזרים וביטולים

1. ביטול הזמנה יתאפשר עד 24 שעות לפני מועד השימוש.
2. החזר כספי מלא יינתן במקרה של ביטול בזמן.
3. ביטול מאוחר יותר לא יקנה החזר כספי, למעט מקרים חריגים באישור הנהלת המקום.
4. במידה ומגרש לא היה זמין עקב תקלה טכנית – יינתן החזר אוטומטי.
5. יש לפנות לשירות הלקוחות לכל בקשה חריגה בנושא ביטולים.

לפרטים נוספים ניתן ליצור קשר עם שירות הלקוחות שלנו במייל: mikron30@gmail.com
            ''',
            textDirection: TextDirection.rtl,
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }
}
