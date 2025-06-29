import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: ADD YOUR API KEY HERE, 
      appId: ADD YOUR APP ID HERE, 
      messagingSenderId: MESSAGINGSENDER ID, 
      projectId: PROJECT ID)
  );
  runApp(LuckyResortApp());
}

class LuckyResortApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lucky Resort Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
        visualDensity: VisualDensity.adaptivePlatformDensity,
        cardTheme: CardThemeData(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ),
      home: FrontDeskDashboard(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class Booking {
  String id;
  String guestName;
  String guestNIC;
  String roomNumber;
  bool isACEnabled;
  DateTime checkInDate;
  DateTime checkOutDate;
  double totalAmount;
  String status; // 'active', 'completed', 'cancelled'

  Booking({
    required this.id,
    required this.guestName,
    required this.guestNIC,
    required this.roomNumber,
    required this.isACEnabled,
    required this.checkInDate,
    required this.checkOutDate,
    required this.totalAmount,
    this.status = 'active',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'guestName': guestName,
      'guestNIC': guestNIC,
      'roomNumber': roomNumber,
      'isACEnabled': isACEnabled,
      'checkInDate': checkInDate.millisecondsSinceEpoch,
      'checkOutDate': checkOutDate.millisecondsSinceEpoch,
      'totalAmount': totalAmount,
      'status': status,
    };
  }

  static Booking fromMap(Map<String, dynamic> map) {
    return Booking(
      id: map['id'],
      guestName: map['guestName'],
      guestNIC: map['guestNIC'],
      roomNumber: map['roomNumber'],
      isACEnabled: map['isACEnabled'],
      checkInDate: DateTime.fromMillisecondsSinceEpoch(map['checkInDate']),
      checkOutDate: DateTime.fromMillisecondsSinceEpoch(map['checkOutDate']),
      totalAmount: map['totalAmount'].toDouble(),
      status: map['status'] ?? 'active',
    );
  }
}

class FrontDeskDashboard extends StatefulWidget {
  @override
  _FrontDeskDashboardState createState() => _FrontDeskDashboardState();
}

class _FrontDeskDashboardState extends State<FrontDeskDashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> rooms = List.generate(8, (index) => 'LR${(index + 1).toString().padLeft(2, '0')}');
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.hotel, color: Colors.white),
            SizedBox(width: 12),
            Text('Lucky Resort - Front Desk', 
                 style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
        backgroundColor: Colors.indigo[800],
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQuickStats(),
            SizedBox(height: 24),
            _buildActionButtons(),
            SizedBox(height: 24),
            _buildRoomAvailability(),
            SizedBox(height: 24),
            _buildRecentBookings(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('bookings').where('status', isEqualTo: 'active').snapshots(),
      builder: (context, snapshot) {
        int occupiedRooms = 0;
        double todayRevenue = 0;
        
        if (snapshot.hasData) {
          occupiedRooms = snapshot.data!.docs.length;
          for (var doc in snapshot.data!.docs) {
            final booking = Booking.fromMap(doc.data() as Map<String, dynamic>);
            if (booking.checkInDate.day == DateTime.now().day) {
              todayRevenue += booking.totalAmount;
            }
          }
        }

        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Occupied Rooms', 
                '$occupiedRooms/8', 
                Icons.hotel, 
                Colors.blue,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Available Rooms', 
                '${8 - occupiedRooms}/8', 
                Icons.hotel_outlined, 
                Colors.green,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Today Revenue', 
                'Rs. ${todayRevenue.toStringAsFixed(0)}', 
                Icons.attach_money, 
                Colors.orange,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 32),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _showBookingDialog(),
            icon: Icon(Icons.add_business),
            label: Text('New Booking'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo[700],
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _showBillGenerationDialog(),
            icon: Icon(Icons.receipt_long),
            label: Text('Generate Bill'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoomAvailability() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Room Availability',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 16),
          StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('bookings').where('status', isEqualTo: 'active').snapshots(),
            builder: (context, snapshot) {
              Set<String> occupiedRooms = {};
              if (snapshot.hasData) {
                for (var doc in snapshot.data!.docs) {
                  final booking = Booking.fromMap(doc.data() as Map<String, dynamic>);
                  occupiedRooms.add(booking.roomNumber);
                }
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: rooms.length,
                itemBuilder: (context, index) {
                  final room = rooms[index];
                  final isOccupied = occupiedRooms.contains(room);
                  
                  return Container(
                    decoration: BoxDecoration(
                      color: isOccupied ? Colors.red[100] : Colors.green[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isOccupied ? Colors.red[300]! : Colors.green[300]!,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isOccupied ? Icons.hotel : Icons.hotel_outlined,
                          color: isOccupied ? Colors.red[600] : Colors.green[600],
                          size: 28,
                        ),
                        SizedBox(height: 4),
                        Text(
                          room,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isOccupied ? Colors.red[700] : Colors.green[700],
                          ),
                        ),
                        Text(
                          isOccupied ? 'Occupied' : 'Available',
                          style: TextStyle(
                            fontSize: 10,
                            color: isOccupied ? Colors.red[600] : Colors.green[600],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecentBookings() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Bookings',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 16),
          StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('bookings').orderBy('checkInDate', descending: true).limit(5).snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Text(
                    'No bookings yet',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final booking = Booking.fromMap(snapshot.data!.docs[index].data() as Map<String, dynamic>);
                  return _buildBookingCard(booking);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(Booking booking) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: booking.status == 'active' ? Colors.green[100] : Colors.grey[100],
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(
              Icons.person,
              color: booking.status == 'active' ? Colors.green[600] : Colors.grey[600],
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.guestName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Room ${booking.roomNumber} • ${booking.isACEnabled ? "A/C" : "Non A/C"}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                Text(
                  '${DateFormat('MMM dd').format(booking.checkInDate)} - ${DateFormat('MMM dd').format(booking.checkOutDate)}',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Rs. ${booking.totalAmount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.indigo[700],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: booking.status == 'active' ? Colors.green[100] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  booking.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    color: booking.status == 'active' ? Colors.green[700] : Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showBookingDialog() {
    showDialog(
      context: context,
      builder: (context) => BookingDialog(
        availableRooms: rooms,
        onBookingCreated: () => setState(() {}),
      ),
    );
  }

  void _showBillGenerationDialog() {
    showDialog(
      context: context,
      builder: (context) => BillGenerationDialog(),
    );
  }
}

class BookingDialog extends StatefulWidget {
  final List<String> availableRooms;
  final VoidCallback onBookingCreated;

  BookingDialog({required this.availableRooms, required this.onBookingCreated});

  @override
  _BookingDialogState createState() => _BookingDialogState();
}

class _BookingDialogState extends State<BookingDialog> {
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;
  
  final _nameController = TextEditingController();
  final _nicController = TextEditingController();
  
  String? selectedRoom;
  bool isACEnabled = true;
  DateTime checkInDate = DateTime.now();
  DateTime checkOutDate = DateTime.now().add(Duration(days: 1));
  
  final double acRate = 7500.0;
  final double nonAcRate = 5000.0;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 500,
        padding: EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'New Booking',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo[800],
                ),
              ),
              SizedBox(height: 24),
              
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Guest Name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) => value?.isEmpty == true ? 'Please enter guest name' : null,
              ),
              SizedBox(height: 16),
              
              TextFormField(
                controller: _nicController,
                decoration: InputDecoration(
                  labelText: 'NIC Number',
                  prefixIcon: Icon(Icons.badge),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) => value?.isEmpty == true ? 'Please enter NIC number' : null,
              ),
              SizedBox(height: 16),
              
              StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('bookings').where('status', isEqualTo: 'active').snapshots(),
                builder: (context, snapshot) {
                  Set<String> occupiedRooms = {};
                  if (snapshot.hasData) {
                    for (var doc in snapshot.data!.docs) {
                      final booking = Booking.fromMap(doc.data() as Map<String, dynamic>);
                      occupiedRooms.add(booking.roomNumber);
                    }
                  }
                  
                  final availableRooms = widget.availableRooms.where((room) => !occupiedRooms.contains(room)).toList();
                  
                  return DropdownButtonFormField<String>(
                    value: selectedRoom,
                    decoration: InputDecoration(
                      labelText: 'Select Room',
                      prefixIcon: Icon(Icons.hotel),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: availableRooms.map((room) => DropdownMenuItem(
                      value: room,
                      child: Text(room),
                    )).toList(),
                    onChanged: (value) => setState(() => selectedRoom = value),
                    validator: (value) => value == null ? 'Please select a room' : null,
                  );
                },
              ),
              SizedBox(height: 16),
              
              SwitchListTile(
                title: Text('Air Conditioning'),
                subtitle: Text(isACEnabled ? 'Rs. 7,500/day' : 'Rs. 5,000/day'),
                value: isACEnabled,
                onChanged: (value) => setState(() => isACEnabled = value),
                activeColor: Colors.indigo[700],
              ),
              SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(true),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Check-in Date',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(DateFormat('MMM dd, yyyy').format(checkInDate)),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(false),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Check-out Date',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(DateFormat('MMM dd, yyyy').format(checkOutDate)),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.indigo[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Amount:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      'Rs. ${_calculateTotal().toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo[700],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _createBooking,
                      child: Text('Create Booking'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo[700],
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _calculateTotal() {
    final days = checkOutDate.difference(checkInDate).inDays;
    final rate = isACEnabled ? acRate : nonAcRate;
    return days * rate;
  }

  Future<void> _selectDate(bool isCheckIn) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isCheckIn ? checkInDate : checkOutDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    
    if (date != null) {
      setState(() {
        if (isCheckIn) {
          checkInDate = date;
          if (checkOutDate.isBefore(checkInDate.add(Duration(days: 1)))) {
            checkOutDate = checkInDate.add(Duration(days: 1));
          }
        } else {
          checkOutDate = date;
        }
      });
    }
  }

  Future<void> _createBooking() async {
    if (!_formKey.currentState!.validate()) return;
    
    final booking = Booking(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      guestName: _nameController.text,
      guestNIC: _nicController.text,
      roomNumber: selectedRoom!,
      isACEnabled: isACEnabled,
      checkInDate: checkInDate,
      checkOutDate: checkOutDate,
      totalAmount: _calculateTotal(),
    );

    try {
      await _firestore.collection('bookings').doc(booking.id).set(booking.toMap());
      widget.onBookingCreated();
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating booking: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class BillGenerationDialog extends StatefulWidget {
  @override
  _BillGenerationDialogState createState() => _BillGenerationDialogState();
}

class _BillGenerationDialogState extends State<BillGenerationDialog> {
  final _firestore = FirebaseFirestore.instance;
  Booking? selectedBooking;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 600,
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Generate Bill',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.indigo[800],
              ),
            ),
            SizedBox(height: 24),
            
            StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('bookings').where('status', isEqualTo: 'active').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final bookings = snapshot.data!.docs.map((doc) => 
                  Booking.fromMap(doc.data() as Map<String, dynamic>)
                ).toList();

                if (bookings.isEmpty) {
                  return Center(
                    child: Text(
                      'No active bookings available',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  );
                }

                return Column(
                  children: [
                    DropdownButtonFormField<Booking>(
                      value: selectedBooking,
                      decoration: InputDecoration(
                        labelText: 'Select Booking',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: bookings.map((booking) => DropdownMenuItem(
                        value: booking,
                        child: Text('${booking.guestName} - Room ${booking.roomNumber}'),
                      )).toList(),
                      onChanged: (value) => setState(() => selectedBooking = value),
                    ),
                    
                    if (selectedBooking != null) ...[
                      SizedBox(height: 24),
                      _buildBillPreview(selectedBooking!),
                    ],
                  ],
                );
              },
            ),
            
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel'),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: selectedBooking != null ? _generateBill : null,
                    child: Text('Generate & Check Out'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillPreview(Booking booking) {
    final days = booking.checkOutDate.difference(booking.checkInDate).inDays;
    final rate = booking.isACEnabled ? 7500.0 : 5000.0;
    
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'LUCKY RESORT',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.indigo[800],
            ),
          ),
          Text('Guest House Management System'),
          Divider(height: 24),
          
          _buildBillRow('Guest Name:', booking.guestName),
          _buildBillRow('NIC:', booking.guestNIC),
          _buildBillRow('Room Number:', booking.roomNumber),
          _buildBillRow('Room Type:', booking.isACEnabled ? 'A/C' : 'Non A/C'),
          _buildBillRow('Check-in:', DateFormat('MMM dd, yyyy - hh:mm a').format(booking.checkInDate)),
          _buildBillRow('Check-out:', DateFormat('MMM dd, yyyy - hh:mm a').format(booking.checkOutDate)),
          _buildBillRow('Number of Days:', days.toString()),
          _buildBillRow('Rate per Day:', 'Rs. ${rate.toStringAsFixed(0)}'),
          
          Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Rs. ${booking.totalAmount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo[700],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBillRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }

  Future<void> _generateBill() async {
    if (selectedBooking == null) return;
    
    try {
      // Update booking status to completed
      await _firestore.collection('bookings').doc(selectedBooking!.id).update({
        'status': 'completed',
        'checkOutDate': DateTime.now().millisecondsSinceEpoch,
      });
      
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bill generated and guest checked out successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Show bill dialog
      _showBillDialog(selectedBooking!);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating bill: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showBillDialog(Booking booking) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 400,
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 48,
              ),
              SizedBox(height: 16),
              Text(
                'Bill Generated Successfully!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Guest ${booking.guestName} has been checked out from room ${booking.roomNumber}.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo[700],
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
