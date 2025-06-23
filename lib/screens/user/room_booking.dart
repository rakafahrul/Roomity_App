import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:table_calendar/table_calendar.dart';
import 'package:time_range_picker/time_range_picker.dart';
import 'package:rom_app/models/booking.dart';
import 'package:rom_app/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RoomBookingScreen extends StatefulWidget {
  final int roomId;
  final String roomName;
  final int roomCapacity;
  final String roomLocation;
  final String roomDescription;
  final String roomPhotoUrl;
  final DateTime? roomCreatedAt;
  final List<dynamic> roomFacilities;
  final DateTime? initialDate;

  const RoomBookingScreen({
    super.key,
    required this.roomId,
    required this.roomName,
    required this.roomCapacity,
    required this.roomLocation,
    required this.roomDescription,
    required this.roomPhotoUrl,
    required this.roomCreatedAt,
    required this.roomFacilities,
    this.initialDate,
  });

  @override
  State<RoomBookingScreen> createState() => _RoomBookingScreenState();
}

class _RoomBookingScreenState extends State<RoomBookingScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  final TextEditingController _activityController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
    _startTime = const TimeOfDay(hour: 8, minute: 0);
    _endTime = const TimeOfDay(hour: 15, minute: 0);
  }

  Future<void> _showCustomDatePicker() async {
    DateTime tempSelected = _selectedDate ?? DateTime.now();
    DateTime? pickedDate = await showDialog<DateTime>(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Pilih Tanggal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 8),
                TableCalendar(
                  firstDay: DateTime.now(),
                  lastDay: DateTime.now().add(const Duration(days: 365)),
                  focusedDay: tempSelected,
                  selectedDayPredicate: (day) => isSameDay(tempSelected, day),
                  onDaySelected: (selected, focused) {
                    setState(() {
                      tempSelected = selected;
                    });
                  },
                  calendarFormat: CalendarFormat.month,
                  headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
                  daysOfWeekStyle: const DaysOfWeekStyle(
                    weekendStyle: TextStyle(color: Colors.black54),
                    weekdayStyle: TextStyle(color: Colors.black54),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      child: const Text('Cancel', style: TextStyle(color: Colors.red)),
                      onPressed: () => Navigator.pop(context),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF192965),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Apply'),
                      onPressed: () => Navigator.pop(context, tempSelected),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
    if (pickedDate != null) {
      setState(() => _selectedDate = pickedDate);
    }
  }

  Future<void> _pickTimeRange() async {
    final picked = await showTimeRangePicker(
      context: context,
      start: _startTime ?? TimeOfDay(hour: 8, minute: 0),
      end: _endTime ?? TimeOfDay(hour: 15, minute: 0),
    );
    if (picked != null) {
      setState(() {
        _startTime = picked.startTime;
        _endTime = picked.endTime;
      });
    }
  }

  Future<void> _handleBooking() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user_data');
      if (userJson == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data user tidak ditemukan! Silakan login ulang.')),
        );
        Navigator.pushReplacementNamed(context, '/user/login');
        return;

      }
      final user = json.decode(userJson);

      if (user['id'] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ID user tidak ditemuka')),
        );
        return;
      }

      if (_selectedDate == null || _startTime == null || _endTime == null || _activityController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lengkapi semua data booking')));
        return;
      }


      setState(() => _isLoading = true);

      bool success = await ApiService.createBookingSwagger(
        user['id'],
        widget.roomId,
        _selectedDate!,
        _activityController.text,
        _startTime!.format(context),
        _endTime!.format(context),
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (success) {
        Navigator.pushReplacementNamed(context, '/user/booking_success');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menyimpan booking! Coba lagi nanti.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Peminjaman Ruang', style: TextStyle(color: Color(0xFF222B45))),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF222B45)),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            GestureDetector(
              onTap: _showCustomDatePicker,
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, color: Color(0xFF222B45)),
                    const SizedBox(width: 12),
                    const Text('Tanggal', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    const Spacer(),
                    Text(
                      _selectedDate != null
                          ? DateFormat('MMM dd, yyyy', 'id_ID').format(_selectedDate!)
                          : '-',
                      style: const TextStyle(fontSize: 15, color: Color(0xFF222B45)),
                    ),
                  ],
                ),
              ),
            ),
            
            GestureDetector(
              onTap: _pickTimeRange,
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time_rounded, color: Color(0xFF222B45)),
                    const SizedBox(width: 12),
                    const Text('Jam', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    const Spacer(),
                    Text(
                      '${_startTime?.format(context) ?? '--:--'} - ${_endTime?.format(context) ?? '--:--'} WIB',
                      style: const TextStyle(fontSize: 15, color: Color(0xFF222B45)),
                    ),
                  ],
                ),
              ),
            ),
            
            const Text('Kegiatan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 4),
            TextField(
              controller: _activityController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: '(jelaskan alasan atau kegiatan yang akan anda lakukan dengan melakukan peminjaman ruangan ini)',
                border: InputBorder.none,
                filled: true,
                fillColor: Color(0xFFF7F7FA),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              style: const TextStyle(fontSize: 15),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF192965),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Pinjam',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}