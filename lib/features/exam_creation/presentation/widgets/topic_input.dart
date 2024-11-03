import 'package:flutter/material.dart';

class TopicInput extends StatefulWidget {
  final List<String> topics;
  final ValueChanged<List<String>> onTopicsChanged;

  const TopicInput({
    super.key,
    required this.topics,
    required this.onTopicsChanged,
  });

  @override
  State<TopicInput> createState() => _TopicInputState();
}

class _TopicInputState extends State<TopicInput> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addTopic() {
    final topic = _controller.text.trim();
    if (topic.isNotEmpty && !widget.topics.contains(topic)) {
      final newTopics = [...widget.topics, topic];
      widget.onTopicsChanged(newTopics);
      _controller.clear();
    }
  }

  void _removeTopic(String topic) {
    final newTopics = widget.topics.where((t) => t != topic).toList();
    widget.onTopicsChanged(newTopics);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: 'Konular',
                  hintText: 'Konu eklemek için Enter\'a basın',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => _addTopic(),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _addTopic,
            ),
          ],
        ),
        if (widget.topics.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: widget.topics.map((topic) {
              return Chip(
                label: Text(topic),
                onDeleted: () => _removeTopic(topic),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
