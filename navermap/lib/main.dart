import 'dart:async';
import 'dart:developer' show log;
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

void main() async {
  await _initialize();
  runApp(const NaverMapApp());
}

//네이버 인증 부분
Future<void> _initialize() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NaverMapSdk.instance.initialize(
      clientId: 's5bm2ba7yr',
      onAuthFailed: (ex) => log("********* 네이버맵 인증오류 : $ex *********"));
}

class NaverMapApp extends StatelessWidget {
  final int? testId;
  const NaverMapApp({super.key, this.testId});

  @override
  Widget build(BuildContext context) => MaterialApp(
      home: testId == null
          ? const TestPage()
          : TestPage(key: Key("testPage_$testId")));
}

class TestPage extends StatefulWidget {
  const TestPage({Key? key}) : super(key: key);

  @override
  State<TestPage> createState() => TestPageState();
}

class TestPageState extends State<TestPage> {
  late NaverMapController _mapController;
  final Completer<NaverMapController> mapControllerCompleter = Completer();

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final pixelRatio = mediaQuery.devicePixelRatio;
    final mapSize =
        Size(mediaQuery.size.width - 10, mediaQuery.size.height - 10);
    final physicalSize =
        Size(mapSize.width * pixelRatio, mapSize.height * pixelRatio);

    print("physicalSize: $physicalSize");

    return Scaffold(
      backgroundColor: const Color(0xFF343945),
      body: Center(
        child: SizedBox(
          width: mapSize.width,
          height: mapSize.height,
          child: _naverMapSection(),
        ),
      ),
    );
  }

  // 네이버 지도 위젯을 생성하는 부분
  Widget _naverMapSection() => NaverMap(
        options: const NaverMapViewOptions(
          // 초기 카메라 위치 설정: 순천향 대학교로 설정
          initialCameraPosition: NCameraPosition(
            target: NLatLng(36.770769, 126.9316), // 위도 경도
            zoom: 15, // 확대 축소 레벨
            bearing: 0,
            tilt: 0,
          ),
          indoorEnable: true, // 지도 내의 실내 맵을 표시할 수 있는 기능
          locationButtonEnable: false, // 현재 위치를 표시하는 버튼의 활성화 여부
          consumeSymbolTapEvents: false,
        ),
        onMapReady: (controller) async {
          _mapController = controller;
          mapControllerCompleter.complete(controller);
          log("onMapReady", name: "onMapReady");

          // 지도 위에 두 개의 마커 추가
          final s_marker =
              NMarker(id: 'test', position: const NLatLng(36.770769, 126.9316));
          final e_marker = NMarker(
              id: 'test1', position: const NLatLng(36.769005, 126.934844));
          controller.addOverlayAll({s_marker, e_marker});

          // 시작마커의 정보창 열기 (소운동장 마커)
          final show_smarker =
              NInfoWindow.onMarker(id: s_marker.info.id, text: "출발");
          s_marker.openInfoWindow(show_smarker);

          final show_emarker =
              NInfoWindow.onMarker(id: e_marker.info.id, text: "도착");
          e_marker.openInfoWindow(show_emarker);
        },
      );
}
