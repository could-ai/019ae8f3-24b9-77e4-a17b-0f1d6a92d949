import 'package:flutter/material.dart';
import '../models/work_order.dart';
import 'create_work_order_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Local list to store work orders (Temporary until database is connected)
  final List<WorkOrder> _workOrders = [];

  void _addNewWorkOrder(WorkOrder order) {
    setState(() {
      _workOrders.insert(0, order); // Add to top of list
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestão de Oficina'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _workOrders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.car_repair, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma folha de obra criada.',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  const Text('Toque no + para criar uma nova.'),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _workOrders.length,
              padding: const EdgeInsets.all(8),
              itemBuilder: (context, index) {
                final order = _workOrders[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      child: const Icon(Icons.assignment),
                    ),
                    title: Text(order.clientName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${order.licensePlate} • ${order.id}'),
                        Text('${order.services.length} serviços'),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${order.totalAmount.toStringAsFixed(2)} €',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        Text(
                          '${order.date.day}/${order.date.month}/${order.date.year}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    onTap: () {
                      // Future: Show details
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateWorkOrderScreen(onSave: _addNewWorkOrder),
            ),
          );
        },
        label: const Text('Nova Folha'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
