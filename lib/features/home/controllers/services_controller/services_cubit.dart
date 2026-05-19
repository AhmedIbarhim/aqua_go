import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/service_model.dart';
import '../../data/repos/services_repository.dart';

part 'services_state.dart';

class ServicesCubit extends Cubit<ServicesState> {
  final ServicesRepository _servicesRepository;

  ServicesCubit({required ServicesRepository servicesRepository})
    : _servicesRepository = servicesRepository,
      super(ServicesInitial());

  Future<void> getServices() async {
    emit(ServicesLoading());
    final result = await _servicesRepository.fetchServices();
    result.fold(
      (failure) => emit(ServicesError(failure.message)),
      (servicesList) => emit(ServicesLoaded(List.from(servicesList))),
    );
  }
}
