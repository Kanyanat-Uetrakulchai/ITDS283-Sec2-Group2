// ..._posts.map((post) {
//                     return Card(
//                       elevation: 3,
//                       margin: EdgeInsets.symmetric(vertical: 10),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.all(16.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               post['caption'] ?? '',
//                               style: TextStyle(
//                                 fontFamily: 'Prompt',
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             SizedBox(height: 6),
//                             Text(post['detail'] ?? ''),
//                             SizedBox(height: 8),
//                             Text('ชื่อมิจฉาชีพ: ${post['mij_name'] ?? '-'}'),
//                             Text('บัญชี: ${post['mij_acc'] ?? '-'}'),
//                             Text(
//                               'ธนาคาร: ${post['mij_bank']} (${post['mij_bankno']})',
//                             ),
//                             Text('แพลตฟอร์ม: ${post['mij_plat'] ?? '-'}'),
//                             SizedBox(height: 4),
//                             Text(
//                               'โพสต์เมื่อ: ${post['p_timestamp'] ?? '-'}',
//                               style: TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.grey,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   }).toList(),