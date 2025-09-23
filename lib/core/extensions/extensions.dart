import 'package:resq360/__lib.dart';

extension GetStringUtils on String {
  String get removeAllWhitespace => replaceAll(' ', '');

  String get capitalize {
    final words = split(' ');
    return words
        .map(
          (word) =>
              word.isNotEmpty
                  ? word[0].toUpperCase() + word.substring(1).toLowerCase()
                  : word,
        )
        .join(' ');
  }

  AssetImage get asset => AssetImage(this);
  Image imageAsset({
    double width = 100,
    double height = 100,
    BoxFit fit = BoxFit.cover,
  }) => Image(
    image: AssetImage(this),
    width: width.w,
    height: height.h,
    fit: fit,
  );
  SvgPicture get svg => SvgPicture.asset(this);

  SvgPicture svgColor({required Color color}) => SvgPicture.asset(
    this,
    colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
  );
}

extension NumberRounding on num {
  num toPrecision(int precision) {
    return num.parse(toStringAsFixed(precision));
  }
}
