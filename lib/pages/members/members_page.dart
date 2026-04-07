import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'add_member_dialog.dart';

class Member {
  final String? id;
  final String fullName;
  final double initialAmount;
  final double targetAmount;
  final DateTime? date;

  Member({
    this.id,
    required this.fullName,
    required this.initialAmount,
    required this.targetAmount,
    this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullname': fullName,
      'initial_amount': initialAmount,
      'target_amount': targetAmount,
      'select_date': date?.toIso8601String(),
    };
  }

  factory Member.fromMap(Map<String, dynamic> map) {
    return Member(
      id: map['id']?.toString(),
      fullName: map['fullname'] ?? '',
      initialAmount: (map['initial_amount'] as num?)?.toDouble() ?? 0.0,
      targetAmount: (map['target_amount'] as num?)?.toDouble() ?? 0.0,
      date: map['select_date'] != null
          ? DateTime.parse(map['select_date'])
          : null,
    );
  }
}

class MembersPage extends StatefulWidget {
  const MembersPage({super.key});

  @override
  State<MembersPage> createState() => _MembersPageState();
}

class _MembersPageState extends State<MembersPage> {
  List<Member> _members = [];
  bool _isLoading = true;
  late final SupabaseClient supabase;

  @override
  void initState() {
    super.initState();
    // Initialize Supabase client with delay to ensure main() initialization completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeSupabase();
    });
  }

  void _initializeSupabase() {
    try {
      supabase = Supabase.instance.client;
      _fetchMembers();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Supabase initialization error: $e')),
        );
      }
    }
  }

  Future<void> _fetchMembers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await supabase
          .from('members')
          .select()
          .order('created_at', ascending: false);

      final members =
          (response as List).map((member) => Member.fromMap(member)).toList();

      setState(() {
        _members = members;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching members: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Members'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchMembers,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _members.isEmpty
              ? const Center(
                  child: Text('No members yet'),
                )
              : ListView.builder(
                  itemCount: _members.length,
                  itemBuilder: (context, index) {
                    final member = _members[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.shade100,
                          child: Text(
                            member.fullName.isNotEmpty
                                ? member.fullName[0].toUpperCase()
                                : 'M',
                            style: TextStyle(
                              color: Colors.blue.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          member.fullName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (member.date != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'select_Date: ${member.date!.day}/${member.date!.month}/${member.date!.year}',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                            const SizedBox(height: 4),
                            Text(
                              'Initial Amount: ₱${member.initialAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Target: ₱${member.targetAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert),
                          onSelected: (value) {
                            if (value == 'delete') {
                              _deleteMember(member.id!, index);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete,
                                      color: Colors.red, size: 20),
                                  SizedBox(width: 8),
                                  Text('Delete Member'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddMemberDialog();
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }

  void _showAddMemberDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const AddMemberDialog(),
    );

    if (result != null) {
      _addMember(
        fullName: result['fullName'],
        initialAmount: result['amount'],
        targetAmount: result['targetAmount'],
        date: result['select_date'],
      );
    }
  }

  Future<void> _addMember({
    required String fullName,
    required double initialAmount,
    required double targetAmount,
    DateTime? date,
  }) async {
    if (fullName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Full name is required')),
      );
      return;
    }

    try {
      final memberData = {
        'fullname': fullName,
        'initial_amount': initialAmount,
        'target_amount': targetAmount,
        'select_date': date?.toIso8601String(),
      };

      await supabase.from('members').insert(memberData);

      await _fetchMembers();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$fullName added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding member: $e')),
        );
      }
    }
  }

  Future<void> _deleteMember(String memberId, int index) async {
    final member = _members[index];

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Member'),
        content: Text('Are you sure you want to delete ${member.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await supabase.from('members').delete().eq('id', memberId);
        await _fetchMembers();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${member.fullName} deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting member: $e')),
          );
        }
      }
    }
  }
}
