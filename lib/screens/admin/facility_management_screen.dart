import 'package:flutter/material.dart';
import 'package:rom_app/models/facility.dart';
import 'package:rom_app/services/api_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rom_app/screens/admin/facility_detail_screen.dart';

class AdminFacilityManagementScreen extends StatefulWidget {
  const AdminFacilityManagementScreen({super.key});

  @override
  _AdminFacilityManagementScreenState createState() => _AdminFacilityManagementScreenState();
}

class _AdminFacilityManagementScreenState extends State<AdminFacilityManagementScreen> {
  List<Facility> _facilities = [];
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchFacilities();
  }

  Future<void> _fetchFacilities() async {
    setState(() => _isLoading = true);
    try {
      final facilities = await _apiService.getFacilities();
      if (mounted) {
        setState(() => _facilities = facilities);
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to load facilities: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _addFacility() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await _apiService.createFacility({'name': _name});
        await _fetchFacilities();
        _formKey.currentState!.reset();
        _name = '';
        if (mounted) {
          _showSuccess('Facility added successfully');
        }
      } catch (e) {
        if (mounted) {
          _showError('Failed to add facility: $e');
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _deleteFacility(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this facility?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isLoading = true);
      try {
        await _apiService.deleteFacility(id);
        await _fetchFacilities();
        if (mounted) {
          _showSuccess('Facility deleted successfully');
        }
      } catch (e) {
        if (mounted) {
          _showError('Failed to delete facility: $e');
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _navigateToFacilityDetail(Facility facility) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminFacilityDetailScreen(facility: facility),
      ),
    );

    if (result == true) {
      _fetchFacilities();
    }
  }

  void _showEditDialog(Facility facility) {
    final controller = TextEditingController(text: facility.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Facility'),
        content: TextFormField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Facility Name'),
          validator: (value) => value!.isEmpty ? 'Enter facility name' : null,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                Navigator.pop(context);
                setState(() => _isLoading = true);
                try {
                  await _apiService.updateFacility(
                    facility.id,
                    {'name': controller.text},
                  );
                  await _fetchFacilities();
                  if (mounted) {
                    _showSuccess('Facility updated successfully');
                  }
                } catch (e) {
                  if (mounted) {
                    _showError('Failed to update facility: $e');
                  }
                } finally {
                  if (mounted) {
                    setState(() => _isLoading = false);
                  }
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  void _showSuccess(String message) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Facility Management')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          decoration: const InputDecoration(labelText: 'Facility Name'),
                          validator: (value) => value!.isEmpty ? 'Enter facility name' : null,
                          onChanged: (value) => _name = value,
                        ),
                        const SizedBox(height: 16.0),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _addFacility,
                            child: const Text('Add Facility'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: _facilities.isEmpty
                        ? const Center(child: Text('No facilities found'))
                        : ListView.builder(
                            itemCount: _facilities.length,
                            itemBuilder: (context, index) {
                              final facility = _facilities[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8.0),
                                child: ListTile(
                                  title: Text(facility.name),
                                  onTap: () => _navigateToFacilityDetail(facility),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: _isLoading ? null : () => _showEditDialog(facility),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        onPressed: _isLoading ? null : () => _deleteFacility(facility.id),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}