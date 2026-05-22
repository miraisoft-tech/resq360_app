import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_place/google_place.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/keys.dart';

mixin LocationSearchMixin<T extends StatefulWidget> on State<T> {
  GooglePlace? googlePlace;
  List<AutocompletePrediction> predictions = [];
  bool isSearchLoading = false;
  bool isBusStop = false;
  String countryCode = 'ng';
  String? debugErrorMessage;

  Future<void> initializeGooglePlace(String googleApiKey) async {
    googlePlace = GooglePlace(
      googleApiKey,
      headers: await const GoogleApiHeaders().getHeaders(),
    );
  }

  Future<DetailsResult?> getLocationDetails(String placeId) async {
    final result = await googlePlace!.details.get(placeId);
    return result?.result;
  }

  Future<void> autoCompleteSearch(String value) async {
    final query = value.trim();
    if (query.isEmpty) {
      if (mounted) {
        setState(() {
          predictions = [];
          isSearchLoading = false;
          debugErrorMessage = null;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        isSearchLoading = true;
        debugErrorMessage = null;
      });
    }

    if (googlePlace == null) {
      if (mounted) {
        setState(() {
          isSearchLoading = false;
          debugErrorMessage =
              kDebugMode ? 'Google Places is not initialized.' : null;
        });
      }
      return;
    }

    try {
      final result = await googlePlace!.autocomplete.get(
        query,
        region: _normalizedCountryCode,
        types: isBusStop ? 'bus_station' : null,
        components: [Component('country', _normalizedCountryCode)],
      );

      if (!mounted) return;
      setState(() {
        predictions = result?.predictions ?? [];
        isSearchLoading = false;
      });
    } on Exception catch (error) {
      if (!mounted) return;
      setState(() {
        predictions = [];
        isSearchLoading = false;
        debugErrorMessage = kDebugMode ? error.toString() : null;
      });
    }
  }

  String get _normalizedCountryCode {
    final normalizedCountryCode = countryCode.trim().toLowerCase();
    return normalizedCountryCode.isEmpty ? 'ng' : normalizedCountryCode;
  }
}

class GooglePlacesAutocompleteField extends StatefulWidget {
  const GooglePlacesAutocompleteField({
    required this.controller,
    required this.onPredictionSelected,
    this.label = 'Address',
    this.hintText = 'Search for an address',
    this.onPlaceDetailsSelected,
    this.isBusStop = false,
    this.countryCode = 'ng',
    super.key,
  });

  final TextEditingController controller;
  final void Function(AutocompletePrediction prediction) onPredictionSelected;
  final void Function(DetailsResult place)? onPlaceDetailsSelected;
  final String label;
  final String hintText;
  final bool isBusStop;
  final String countryCode;

  @override
  State<GooglePlacesAutocompleteField> createState() =>
      _GooglePlacesAutocompleteFieldState();
}

class _GooglePlacesAutocompleteFieldState
    extends State<GooglePlacesAutocompleteField> {
  bool _isLoadingPlaceDetails = false;

  Future<AutocompletePrediction?> pickOriginRoute({
    bool isBusStop = false,
  }) async {
    final googleApiKey = (await AppKeys.googleApiKey).trim();
    if (googleApiKey.isEmpty) {
      if (mounted) {
        await showErrorSnackbar(
          context,
          'Add GOOGLE_API_KEY to keys.json to use address search.',
        );
      }
      return null;
    }

    final result = await Navigator.of(
      context,
      rootNavigator: true,
    ).push<AutocompletePrediction>(
      MaterialPageRoute<AutocompletePrediction>(
        builder: (context) {
          return PlacePickerPage(
            googleApiKey: googleApiKey,
            label: widget.hintText,
            isBusStop: isBusStop,
            countryCode: widget.countryCode,
          );
        },
        fullscreenDialog: true,
      ),
    );

    return result;
  }

  Future<void> _openPlacePicker() async {
    clearFocus(context);

    final result = await pickOriginRoute(isBusStop: widget.isBusStop);
    if (result == null || !mounted) return;

    final description = result.description ?? '';
    widget.controller.text = description;
    widget.onPredictionSelected(result);

    if (widget.onPlaceDetailsSelected == null) return;

    final placeId = result.placeId;
    if (placeId == null || placeId.isEmpty) return;

    setState(() {
      _isLoadingPlaceDetails = true;
    });

    try {
      final details = await _getLocationDetails(placeId);
      if (!mounted) return;

      if (details != null) {
        widget.onPlaceDetailsSelected?.call(details);
      }
    } on Exception catch (error) {
      if (!mounted) return;
      await showErrorSnackbar(
        context,
        kDebugMode
            ? error.toString()
            : 'Unable to select address. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingPlaceDetails = false;
        });
      }
    }
  }

  Future<DetailsResult?> _getLocationDetails(String placeId) async {
    final googleApiKey = (await AppKeys.googleApiKey).trim();
    if (googleApiKey.isEmpty) {
      throw Exception('Add GOOGLE_API_KEY to keys.json to use address search.');
    }

    final googlePlace = GooglePlace(
      googleApiKey,
      headers: await const GoogleApiHeaders().getHeaders(),
    );
    final result = await googlePlace.details.get(placeId);
    return result?.result;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _openPlacePicker,
          child: AbsorbPointer(
            child: KFormField(
              label: widget.label,
              controller: widget.controller,
              hintText: widget.hintText,
              maxLines: 3,
            ),
          ),
        ),
        if (_isLoadingPlaceDetails) ...[
          8.verticalSpace,
          LinearProgressIndicator(color: context.appColors.primary.shade500),
        ],
      ],
    );
  }
}

class PlacePickerPage extends StatefulWidget {
  const PlacePickerPage({
    required this.googleApiKey,
    required this.label,
    this.isBusStop = false,
    this.countryCode = 'ng',
    super.key,
  });

  final String googleApiKey;
  final String label;
  final bool isBusStop;
  final String countryCode;

  @override
  State<PlacePickerPage> createState() => _PlacePickerPageState();
}

class _PlacePickerPageState extends State<PlacePickerPage>
    with LocationSearchMixin<PlacePickerPage> {
  final TextEditingController searchBoxController = TextEditingController();
  final FocusNode searchBoxNode = FocusNode();

  @override
  void initState() {
    super.initState();
    isBusStop = widget.isBusStop;
    countryCode = widget.countryCode;
    unawaited(initializeGooglePlace(widget.googleApiKey));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future<void>.delayed(const Duration(milliseconds: 300), () {
        if (mounted) searchBoxNode.requestFocus();
      });
    });
  }

  @override
  void dispose() {
    searchBoxController.dispose();
    searchBoxNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;

    return Scaffold(
      backgroundColor: appColors.whiteColor,
      appBar: AppBar(
        forceMaterialTransparency: true,
        backgroundColor: appColors.whiteColor,
        foregroundColor: appColors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: appColors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: UrbText(
          widget.label,
          size: 18,
          weight: FontWeight.w700,
          color: appColors.black,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: pad(horizontal: 16, vertical: 12),
          child: Column(
            children: [
              TextField(
                controller: searchBoxController,
                focusNode: searchBoxNode,
                autocorrect: false,
                textInputAction: TextInputAction.search,
                cursorColor: appColors.primary.shade500,
                style: TextStyle(color: appColors.black),
                decoration: InputDecoration(
                  hintText: widget.label,
                  filled: true,
                  fillColor: appColors.whiteColor,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: appColors.lightGreyColor3,
                      width: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: appColors.primary.shade500),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  suffixIcon:
                      searchBoxController.text.isEmpty
                          ? null
                          : IconButton(
                            icon: Icon(
                              Icons.cancel,
                              color: appColors.neutral.shade400,
                            ),
                            onPressed: () {
                              searchBoxController.clear();
                              setState(() => predictions = []);
                            },
                          ),
                ),
                onChanged: (value) {
                  setState(() {});
                  if (value.isEmpty) {
                    setState(() => predictions = []);
                    return;
                  }
                  unawaited(autoCompleteSearch(value));
                },
              ),
              if (isSearchLoading) ...[
                8.verticalSpace,
                LinearProgressIndicator(color: appColors.primary.shade500),
              ],
              if (debugErrorMessage != null) ...[
                10.verticalSpace,
                Align(
                  alignment: Alignment.centerLeft,
                  child: UrbText(
                    debugErrorMessage!,
                    size: 12,
                    color: appColors.error.shade500,
                  ),
                ),
              ],
              8.verticalSpace,
              Expanded(
                child: ListView.separated(
                  itemCount: predictions.length,
                  separatorBuilder: (context, index) {
                    return Divider(height: 1, color: appColors.lightGreyColor3);
                  },
                  itemBuilder: (context, index) {
                    final prediction = predictions[index];
                    return _GooglePlacePredictionTile(
                      prediction: prediction,
                      onTap: () => Navigator.of(context).pop(prediction),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GooglePlacePredictionTile extends StatelessWidget {
  const _GooglePlacePredictionTile({
    required this.prediction,
    required this.onTap,
  });

  final AutocompletePrediction prediction;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final title =
        prediction.structuredFormatting?.mainText ??
        prediction.description ??
        '';
    final subtitle = prediction.structuredFormatting?.secondaryText;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: pad(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              color: appColors.primary.shade500,
              size: 20.sp,
            ),
            10.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UrbText(
                    title,
                    weight: FontWeight.w600,
                    color: appColors.black,
                    maxLines: 1,
                  ),
                  if (subtitle != null && subtitle.isNotEmpty) ...[
                    3.verticalSpace,
                    UrbText(
                      subtitle,
                      size: 12,
                      color: appColors.textColor.shade400,
                      maxLines: 2,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
