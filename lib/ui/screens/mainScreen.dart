import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:open_nizvpn/core/models/dnsConfig.dart';
import 'package:open_nizvpn/core/models/vpnConfig.dart';
import 'package:open_nizvpn/core/models/vpnStatus.dart';
import 'package:open_nizvpn/core/utils/nizvpn_engine.dart';
import 'package:flutter/services.dart' show rootBundle;

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String _vpnState = NizVpn.vpnDisconnected;
  List<VpnConfig> _listVpn = [];
  List<String> _bypass = ["id.nizwar.open_nizvpn"];
  String dns1='1.1.1.1', dns2='2.2.2.2';
  List<String> _firebaseDnsList = ["Dns-1 Settings", "Dns-2 Settings", "Dns-3 Settings", "Dns-4 Settings"];
  VpnConfig _selectedVpn;

  @override
  void initState() {
    super.initState();

    ///Add listener to update vpnstate
    NizVpn.vpnStageSnapshot().listen((event) {
      setState(() {
        _vpnState = event;
      });
    });

    ///Call initVpn
    initVpn();
  }

  ///Here you can start fill the listVpn, for this simple app, i'm using free vpn from https://www.vpngate.net/
  void initVpn() async {
    _listVpn.add(VpnConfig(
        config: await rootBundle.loadString("assets/vpn/us.ovpn"),
        name: _firebaseDnsList[0]));
    _listVpn.add(VpnConfig(
        config: await rootBundle.loadString("assets/vpn/us.ovpn"),
        name: _firebaseDnsList[1]
    ));
    _listVpn.add(VpnConfig(
        config: await rootBundle.loadString("assets/vpn/us.ovpn"),
        name: _firebaseDnsList[2]));
    _listVpn.add(VpnConfig(
        config: await rootBundle.loadString("assets/vpn/japan.ovpn"),
        name: _firebaseDnsList[3]));
    if (mounted)
      setState(() {
        _selectedVpn = _listVpn.first;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Demo Dns Test"),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          physics: BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: FlatButton(
                  shape: StadiumBorder(),
                  child: Text(
                    _vpnState == NizVpn.vpnDisconnected
                        ? "Apply Selected Settings"
                        : _vpnState.replaceAll("_", " ").toUpperCase(),
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: _connectClick,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              StreamBuilder<VpnStatus>(
                initialData: VpnStatus(),
                stream: NizVpn.vpnStatusSnapshot(),
                builder: (context, snapshot) => Text(
                    "${snapshot?.data?.byteIn ?? ""}, ${snapshot?.data?.byteOut ?? ""}",
                    textAlign: TextAlign.center),
              )
            ]
              //i just make it simple, hope i'm not making you to much confuse
              ..addAll(
                _listVpn != null && _listVpn.length > 0
                    ? _listVpn.map(
                        (e) => ListTile(
                          title: Text(e.name),
                          leading: SizedBox(
                            height: 20,
                            width: 20,
                            child: Center(
                                child: _selectedVpn == e
                                    ? CircleAvatar(
                                        backgroundColor: Colors.green)
                                    : CircleAvatar(
                                        backgroundColor: Colors.grey)),
                          ),
                          onTap: () {
                            if (_selectedVpn == e) return;
                            log("${e.name} is selected");
                            NizVpn.stopVpn();
                            setState(() {
                              _selectedVpn = e;
                            });
                          },
                        ),
                      )
                    : [],
              ),
          ),
        ),
      ),
    );
  }

  void _connectClick() {
    ///Stop right here if user not select a vpn
    if (_selectedVpn == null) return;

    if(_selectedVpn.name == "Dns-1 Settings") {
      dns1 = '1.1.1.1';
      dns2 = '2.2.2.2';
    } else if(_selectedVpn.name == "Dns-2 Settings") {
      dns1 = '1.0.0.1';
      dns2 = '4.4.4.4';
    } else if(_selectedVpn.name == "Dns-3 Settings") {
      dns1 = '5.5.5.5';
      dns2 = '6.6.6.6';
    } else {
      dns1 = '7.7.7.7';
      dns2 = '8.8.8.8';
    }

    if (_vpnState == NizVpn.vpnDisconnected) {
      ///Start if stage is disconnected
      NizVpn.startVpn(
        _selectedVpn,
        dns: DnsConfig(dns1, dns2)
      );
    } else {
      ///Stop if stage is "not" disconnected
      NizVpn.stopVpn();
    }
  }
}
