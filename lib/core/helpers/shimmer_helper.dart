import 'package:carousel_slider/carousel_controller.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

// Models
import '../../features/home/data/models/banner_model.dart';
import '../../features/home/data/models/package_model.dart';
import '../../features/home/data/models/service_model.dart';
import '../../features/home/data/models/offer_model.dart';
import '../../features/my_cars/data/models/my_car_model.dart';
import '../../features/my_cars/data/models/vehicle_make_model.dart';
import '../../features/my_cars/data/models/vehicle_model_model.dart';
import '../../features/address/data/models/address_model.dart';

// Cards / Widgets
import '../../features/home/presentation/widgets/home_banners_carosal.dart';
import '../../features/home/presentation/widgets/package_card.dart';
import '../../features/home/presentation/widgets/service_card.dart';
import '../../features/home/presentation/widgets/offer_card.dart';
import '../../features/my_cars/presentation/widgets/my_car_card.dart';
import '../../features/address/presentation/widgets/my_address_card.dart';
import '../../features/booking/presentation/widgets/car_selection_list.dart';
import '../../features/booking/presentation/widgets/location_selection_card.dart';
import '../utils/app_assets.dart';

class ShimmerHelper extends StatelessWidget {
  final Widget child;
  final bool enabled;

  const ShimmerHelper({super.key, required this.child, this.enabled = true});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(enabled: enabled, child: child);
  }

  // 1. Shimmer list/carousel for banners loading
  static Widget banners({CarouselSliderController? controller}) {
    final activeBanners = [
      BannerModel(
        id: 'shimmer1',
        locale: 'ar',
        imageUrl: 'assets/images/banner_demo.png',
        ctaType: 'NONE',
        sortOrder: 1,
      ),
      BannerModel(
        id: 'shimmer2',
        locale: 'ar',
        imageUrl: 'assets/images/banner_demo.png',
        ctaType: 'NONE',
        sortOrder: 2,
      ),
    ];
    return Skeletonizer(
      enabled: true,
      child: HomeBannersCarosal(
        carouselController: controller ?? CarouselSliderController(),
        banners: activeBanners,
      ),
    );
  }

  static List<PackageModel> getDummyPackages() {
    return List.generate(
      3,
      (index) => PackageModel(
        id: 'shimmer_pkg_$index',
        nameAr: 'باقة اكوا بريميوم النموذجية',
        nameEn: 'Model Aqua Premium Package',
        descriptionAr:
            'هذا الوصف تجريبي لتجربة التحميل الشيمر لباقات أكوا غو المميزة',
        descriptionEn:
            'This description is for testing packages shimmer loading',
        numWashes: 10,
        validityDays: 30,
        priceMinor: 99999,
        currency: 'SAR',
        maxActivePerCustomer: 1,
        allowScheduleLater: true,
        active: true,
        addons: [],
        bundledServiceIds: const [],
        createdAt: '',
        updatedAt: '',
        version: 1,
        imageUrl: 'assets/images/gift_demo.png',
        isPopular: true,
        carsPerWash: 1,
        effectiveFromAt: '',
      ),
    );
  }

  // 2. Shimmer list for packages in HomeView
  static Widget packages({double? height}) {
    final dummyPackages = getDummyPackages();

    return Skeletonizer(
      enabled: true,
      child: SizedBox(
        height: height ?? 140,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: dummyPackages.length,
          separatorBuilder: (context, index) => const SizedBox(width: 16),
          itemBuilder: (context, index) =>
              PackageCard(packageModel: dummyPackages[index], atHome: true),
        ),
      ),
    );
  }

  // 3. Shimmer card for services in HomeView
  static Widget serviceCard({double? height}) {
    final dummyService = ServiceModel(
      id: 'shimmer_service',
      code: 'SHIMMER',
      refNumber: 'SHIMMER',
      rawName: const ServiceName(
        nameAr: 'غسيل واش سوبر تجريبي شيمر',
        nameEn: 'Shimmer Dummy Service Super Wash',
      ),
      rawDescription: const ServiceDescription(
        descAr:
            'هذا الوصف تجريبي لخدمات شيمر الجميلة، غسيل داخلي وخارجي للسيارة مع تلميع الإطارات',
        descEn:
            'This is a description for testing services shimmer, full interior and exterior cleaning with tire polish.',
      ),
      active: true,
      addons: const [],
      priceMinor: 15000,
      vatMinor: 2250,
    );

    return Skeletonizer(
      enabled: true,
      child: SizedBox(
        height: height ?? 120,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: ServiceCard(serviceModel: dummyService),
        ),
      ),
    );
  }

  // 4. Shimmer list for offers in HomeView
  static Widget offers({double? height}) {
    final dummyOffers = List.generate(
      3,
      (index) => OfferModel(image: "assets/images/offer_demo.png"),
    );

    return Skeletonizer(
      enabled: true,
      child: SizedBox(
        height: height ?? 180,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: dummyOffers.length,
          separatorBuilder: (context, index) => const SizedBox(width: 16),
          itemBuilder: (context, index) =>
              OfferCard(offerModel: dummyOffers[index], atHome: true),
        ),
      ),
    );
  }

  // 5. Shimmer list for my cars
  static Widget cars() {
    final dummyCars = List.generate(
      3,
      (index) => MyCarModel(
        id: 'shimmer_car_$index',
        makeId: 'shimmer_brand',
        modelId: 'shimmer_model',
        modelYear: DateTime.now().year,
        color: '#CCCCCC',
        plateNumber: 'أ ب ج ١٢٣٤',
        logoUrl: "assets/images/logo_demo.png",
        carMake: const VehicleMakeModel(
          id: 'brand',
          vehicleMakeName: MakeName(
            nameAr: 'تويوتا نموذج',
            nameEn: 'Toyota Dummy',
          ),
          active: true,
          version: 1,
        ),
        carModel: const VehicleModelModel(
          id: 'model',
          makeId: 'brand',
          vehicleModelName: ModelName(
            nameAr: 'لاند كروزر',
            nameEn: 'Land Cruiser',
          ),
          active: true,
          version: 1,
        ),
      ),
    );

    return Skeletonizer(
      enabled: true,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: dummyCars.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) =>
            MyCarCard(car: dummyCars[index], onEdit: null, onDelete: null),
      ),
    );
  }

  // 6. Shimmer list for my addresses
  static Widget addresses() {
    final dummyAddresses = List.generate(
      3,
      (index) => AddressModel(
        id: 'shimmer_address_$index',
        label: 'المنزل الافتراضي للشيمر',
        details: 'شارع الملك فهد، حي الصحافة، الرياض، المملكة العربية السعودية',
        lat: 24.7136,
        lng: 46.6753,
      ),
    );

    return Skeletonizer(
      enabled: true,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: dummyAddresses.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) => MyAddressCard(
          address: dummyAddresses[index],
          onEdit: () {},
          onDelete: () {},
        ),
      ),
    );
  }

  // 7. Shimmer horizontal selection list for cars in booking flow
  static Widget bookingCars({
    int? selectedCarIndex,
    Function(int)? onCarSelected,
    VoidCallback? onAddCar,
  }) {
    final dummyCars = List.generate(
      3,
      (index) => MyCarModel(
        id: 'shimmer_car_$index',
        makeId: 'shimmer_brand',
        modelId: 'shimmer_model',
        logoUrl: "assets/images/logo_demo.png",

        color: '#CCCCCC',
        modelYear: DateTime.now().year,
        plateNumber: '١٢٣٤',
        carMake: const VehicleMakeModel(
          id: 'brand',
          vehicleMakeName: MakeName(
            nameAr: 'تويوتا نموذج',
            nameEn: 'Toyota Dummy',
          ),
          active: true,
          version: 1,
        ),
        carModel: const VehicleModelModel(
          id: 'model',
          makeId: 'brand',
          vehicleModelName: ModelName(nameAr: 'كامري', nameEn: 'Camry'),
          active: true,
          version: 1,
        ),
      ),
    );

    return Skeletonizer(
      enabled: true,
      child: CarSelectionList(
        cars: dummyCars,
        selectedCarIndex: selectedCarIndex,
        onCarSelected: onCarSelected ?? (index) {},
        onAddCar: onAddCar ?? () {},
      ),
    );
  }

  // 8. Shimmer vertical list for addresses in booking flow
  static Widget bookingAddresses({
    int? selectedAddressIndex,
    Function(int)? onAddressSelected,
  }) {
    final dummyAddresses = List.generate(
      3,
      (index) => AddressModel(
        id: 'shimmer_address_$index',
        label: 'عنوان افتراضي $index',
        details: 'شارع التخصصي، الرياض، المملكة العربية السعودية',
        lat: 24.7136,
        lng: 46.6753,
      ),
    );

    return Skeletonizer(
      enabled: true,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: dummyAddresses.length,
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          final address = dummyAddresses[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: LocationSelectionCard(
              icon: AppAssets.location,
              title: address.label,
              subtitle: address.details,
              isSelected: selectedAddressIndex == index + 1,
              onTap: onAddressSelected != null
                  ? () => onAddressSelected(index + 1)
                  : () {},
            ),
          );
        },
      ),
    );
  }
}
