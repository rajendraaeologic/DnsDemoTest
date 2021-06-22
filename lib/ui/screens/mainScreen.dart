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
  String dns1, dns2;
  List<String> _firebaseDnsList = ["1.1.1.1", "2.2.2.2", "3.3.3.3", "4.4.4.4"];
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
        config: await rootBundle.loadString("assets/vpn/us.ovpn"),
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
                        ? "Connect VPN!"
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
                            if(e.name == "1.1.1.1") {
                              dns1 = '1.1.1.1';
                              dns2 = '2.2.2.2';
                            } else if(e.name == "2.2.2.2") {
                              dns1 = '3.3.3.3';
                              dns2 = '4.4.4.4';
                            } else if(e.name == "3.3.3.3") {
                              dns1 = '5.5.5.5';
                              dns2 = '6.6.6.6';
                            } else {
                              dns1 = '7.7.7.7';
                              dns2 = '8.8.8.8';
                            }
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

    if (_vpnState == NizVpn.vpnDisconnected) {
      ///Start if stage is disconnected
      NizVpn.startVpn(
        _selectedVpn,
        dns: DnsConfig(dns1, dns2),
      );
    } else {
      ///Stop if stage is "not" disconnected
      NizVpn.stopVpn();
    }
  }
}
