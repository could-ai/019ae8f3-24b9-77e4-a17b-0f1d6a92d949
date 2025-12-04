import 'package:flutter/material.dart';
import '../models/work_order.dart';

class CreateWorkOrderScreen extends StatefulWidget {
  final Function(WorkOrder) onSave;

  const CreateWorkOrderScreen({super.key, required this.onSave});

  @override
  State<CreateWorkOrderScreen> createState() => _CreateWorkOrderScreenState();
}

class _CreateWorkOrderScreenState extends State<CreateWorkOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers for header info
  final _clientNameController = TextEditingController();
  final _clientContactController = TextEditingController();
  final _licensePlateController = TextEditingController();
  final _mileageController = TextEditingController();

  // List of services
  final List<ServiceItem> _services = [];

  // Unique ID generation (mock)
  late String _workOrderId;

  @override
  void initState() {
    super.initState();
    // Generate a unique ID based on timestamp for now
    _workOrderId = 'FO-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
  }

  @override
  void dispose() {
    _clientNameController.dispose();
    _clientContactController.dispose();
    _licensePlateController.dispose();
    _mileageController.dispose();
    super.dispose();
  }

  double get _totalAmount {
    return _services.fold(0, (sum, item) => sum + item.price);
  }

  void _addServiceDialog() {
    final descController = TextEditingController();
    final priceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Serviço'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Descrição do Serviço'),
              textCapitalization: TextCapitalization.sentences,
            ),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Valor (€)', suffixText: '€'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (descController.text.isNotEmpty && priceController.text.isNotEmpty) {
                final price = double.tryParse(priceController.text.replaceAll(',', '.')) ?? 0.0;
                setState(() {
                  _services.add(ServiceItem(
                    description: descController.text,
                    price: price,
                  ));
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  void _saveWorkOrder() {
    if (_formKey.currentState!.validate()) {
      if (_services.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Adicione pelo menos um serviço.')),
        );
        return;
      }

      final newOrder = WorkOrder(
        id: _workOrderId,
        clientName: _clientNameController.text,
        clientContact: _clientContactController.text,
        licensePlate: _licensePlateController.text.toUpperCase(),
        mileage: int.tryParse(_mileageController.text) ?? 0,
        services: List.from(_services),
        date: DateTime.now(),
      );

      widget.onSave(newOrder);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nova Folha de Obra: $_workOrderId'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // Client Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Dados do Cliente', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _clientNameController,
                            decoration: const InputDecoration(labelText: 'Nome do Cliente', prefixIcon: Icon(Icons.person)),
                            validator: (value) => value == null || value.isEmpty ? 'Obrigatório' : null,
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _clientContactController,
                            decoration: const InputDecoration(labelText: 'Contacto', prefixIcon: Icon(Icons.phone)),
                            keyboardType: TextInputType.phone,
                            validator: (value) => value == null || value.isEmpty ? 'Obrigatório' : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Vehicle Section
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Dados da Viatura', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _licensePlateController,
                                  decoration: const InputDecoration(labelText: 'Matrícula', prefixIcon: Icon(Icons.directions_car)),
                                  textCapitalization: TextCapitalization.characters,
                                  validator: (value) => value == null || value.isEmpty ? 'Obrigatório' : null,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _mileageController,
                                  decoration: const InputDecoration(labelText: 'Quilómetros', suffixText: 'km'),
                                  keyboardType: TextInputType.number,
                                  validator: (value) => value == null || value.isEmpty ? 'Obrigatório' : null,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Services Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Serviços a Realizar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton.filledTonal(
                        onPressed: _addServiceDialog,
                        icon: const Icon(Icons.add),
                        tooltip: 'Adicionar Serviço',
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_services.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Center(child: Text('Nenhum serviço adicionado.', style: TextStyle(color: Colors.grey))),
                    )
                  else
                    ..._services.asMap().entries.map((entry) {
                      final index = entry.key;
                      final service = entry.value;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(child: Text('${index + 1}')),
                          title: Text(service.description),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('${service.price.toStringAsFixed(2)} €', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _services.removeAt(index);
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
            
            // Footer with Total
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5))
                ]
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('TOTAL ESTIMADO:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('${_totalAmount.toStringAsFixed(2)} €', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton.icon(
                        onPressed: _saveWorkOrder,
                        icon: const Icon(Icons.save),
                        label: const Text('CRIAR FOLHA DE OBRA'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
