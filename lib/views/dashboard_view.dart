import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/product_viewmodel.dart';
import '../viewmodels/chat_viewmodel.dart';
import 'shared_widgets.dart';
import 'add_product_view.dart';
import 'edit_product_view.dart';
import 'product_detail_view.dart';
import 'my_ads_view.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authVM = context.read<AuthViewModel>();
      if (authVM.currentUser != null) {
        final userId = authVM.currentUser!.id;
        context.read<ProductViewModel>().setUserId(userId);
        context.read<ChatViewModel>().setUserId(userId);
        context.read<ProductViewModel>().listenToProducts();
        context.read<ChatViewModel>().listenToConversations();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _navIndex,
          children: [
            const HomeTab(),
            const ExploreTab(),
            const SavedTab(),
            const ChatTab(),
            const ProfileTab(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFE94E92),
        unselectedItemColor: const Color(0xFF8A91A8),
        backgroundColor: Colors.white,
        elevation: 12,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.explore_rounded), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border_rounded), label: 'Saved'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline_rounded), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), label: 'Profile'),
        ],
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer2<ProductViewModel, AuthViewModel>(
      builder: (context, productVM, authVM, _) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Welcome back!', style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF8A91A8))),
                      const SizedBox(height: 2),
                      Text('Discover Deals', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, color: const Color(0xFF1A1D2B))),
                    ],
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProductView()));
                    },
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(color: const Color(0xFFEDEEF2), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.add_rounded, color: Color(0xFF3A3F52)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF8A91A8), size: 22),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  filled: true,
                  fillColor: const Color(0xFFEDEEF2),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
                onChanged: (query) => productVM.searchProducts(query),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              height: 40,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                scrollDirection: Axis.horizontal,
                itemCount: productVM.categories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final selected = productVM.categories[i] == productVM.selectedCategory;
                  return GestureDetector(
                    onTap: () => productVM.selectCategory(productVM.categories[i]),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        gradient: selected ? const LinearGradient(colors: [Color(0xFFFF4F69), Color(0xFFC76FB6)]) : null,
                        color: selected ? null : const Color(0xFFEDEEF2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      alignment: Alignment.center,
                      child: Text(productVM.categories[i], style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700, color: selected ? Colors.white : const Color(0xFF5A6078))),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: productVM.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GridView.builder(
                        itemCount: productVM.products.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 14, crossAxisSpacing: 14, childAspectRatio: 0.72),
                        itemBuilder: (context, i) {
                          final product = productVM.products[i];
                          final isOwner = productVM.isProductOwner(product.sellerId);
                          return ProductCard(
                            name: product.name,
                            category: product.category,
                            price: product.price,
                            rating: product.rating,
                            image: product.image,
                            isFavorite: product.isFavorite,
                            isOwner: isOwner,
                            onCardTap: () async {
                              final result = await showDialog<String>(
                                context: context,
                                builder: (_) => ProductDetailView(product: product),
                              );
                              if (result == 'edit' && isOwner) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => EditProductView(product: product)),
                                );
                              } else if (result == 'delete' && isOwner) {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete Product'),
                                    content: const Text('Are you sure you want to delete this product?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          productVM.deleteProduct(product.id);
                                        },
                                        child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                            onFavoriteTap: () => productVM.toggleFavorite(product.id),
                            onEditTap: isOwner
                                ? () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => EditProductView(product: product)),
                                    );
                                  }
                                : null,
                            onDeleteTap: isOwner
                                ? () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Delete Product'),
                                        content: const Text('Are you sure you want to delete this product?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                              productVM.deleteProduct(product.id);
                                            },
                                            child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                : null,
                          );
                        },
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class ExploreTab extends StatelessWidget {
  const ExploreTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Text('Explore', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, color: const Color(0xFF1A1D2B))),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search categories, brands...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF8A91A8), size: 22),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                filled: true,
                fillColor: const Color(0xFFEDEEF2),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 140,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(18), gradient: const LinearGradient(colors: [Color(0xFFFF4F69), Color(0xFFC76FB6)])),
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Up to 50% Off', style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        Text('Weekend special on electronics', style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70)),
                        const SizedBox(height: 12),
                        Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Text('Shop Now', style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFFE94E92), fontWeight: FontWeight.w700))),
                      ],
                    ),
                  ),
                  const Icon(Icons.local_offer_rounded, size: 64, color: Colors.white24),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SectionHeader(title: 'Trending Now'),
          const SizedBox(height: 12),
          Consumer2<ProductViewModel, AuthViewModel>(
            builder: (context, productVM, authVM, _) {
              final trending = productVM.products.take(4).toList();
              return SizedBox(
                height: 200,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: trending.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 14),
                  itemBuilder: (_, i) => SizedBox(
                    width: 150,
                    child: ProductCard(
                      name: trending[i].name,
                      category: trending[i].category,
                      price: trending[i].price,
                      rating: trending[i].rating,
                      image: trending[i].image,
                      isFavorite: trending[i].isFavorite,
                      isOwner: productVM.isProductOwner(trending[i].sellerId),
                      onCardTap: () async {
                        final result = await showDialog<String>(
                          context: context,
                          builder: (_) => ProductDetailView(product: trending[i]),
                        );
                        if (result == 'edit' && productVM.isProductOwner(trending[i].sellerId)) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => EditProductView(product: trending[i])),
                          );
                        } else if (result == 'delete' && productVM.isProductOwner(trending[i].sellerId)) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Product'),
                              content: const Text('Are you sure you want to delete this product?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    productVM.deleteProduct(trending[i].id);
                                  },
                                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      onFavoriteTap: () => productVM.toggleFavorite(trending[i].id),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class SavedTab extends StatelessWidget {
  const SavedTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<ProductViewModel>(
      builder: (context, productVM, _) {
        final favorites = productVM.favorites;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Text('Saved Items', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, color: const Color(0xFF1A1D2B))),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: Text('${favorites.length} items in your wishlist', style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF8A91A8))),
            ),
            Expanded(
              child: favorites.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.favorite_border_rounded, size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 12),
                          Text('No saved items yet', style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF8A91A8))),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: favorites.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (_, i) {
                        final p = favorites[i];
                        return GestureDetector(
                          onTap: () async {
                            final result = await showDialog<String>(
                              context: context,
                              builder: (_) => ProductDetailView(product: p),
                            );
                            if (result == 'edit' && productVM.isProductOwner(p.sellerId)) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => EditProductView(product: p)),
                              );
                            } else if (result == 'delete' && productVM.isProductOwner(p.sellerId)) {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Product'),
                                  content: const Text('Are you sure you want to delete this product?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        productVM.deleteProduct(p.id);
                                      },
                                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 3))]),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Container(
                                    width: 72,
                                    height: 72,
                                    decoration: BoxDecoration(color: const Color(0xFFEDEEF2), borderRadius: BorderRadius.circular(12)),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(p.image, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported_outlined, color: Color(0xFFB0B5C3))),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(p.name, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700, color: const Color(0xFF1A1D2B))),
                                        const SizedBox(height: 2),
                                        Text(p.category, style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF8A91A8))),
                                        const SizedBox(height: 6),
                                        Text('\$${p.price}', style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w800, color: const Color(0xFFE94E92))),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => productVM.toggleFavorite(p.id),
                                    icon: const Icon(Icons.favorite_rounded, color: Color(0xFFE94E92)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class ChatTab extends StatefulWidget {
  const ChatTab({super.key});

  @override
  State<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> {
  String? _selectedConversationId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_selectedConversationId != null) {
      return _ChatDetailView(
        conversationId: _selectedConversationId!,
        onBack: () => setState(() => _selectedConversationId = null),
      );
    }

    return Consumer<ChatViewModel>(
      builder: (context, chatVM, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                Text('Messages', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, color: const Color(0xFF1A1D2B))),
                const Spacer(),
                if (chatVM.unreadCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFE94E92), borderRadius: BorderRadius.circular(12)),
                    child: Text('${chatVM.conversations.where((c) => c.unreadCount > 0).length} new', style: theme.textTheme.bodySmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search conversations...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF8A91A8), size: 22),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                filled: true,
                fillColor: const Color(0xFFEDEEF2),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: chatVM.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: chatVM.conversations.length,
                    separatorBuilder: (_, _) => const Divider(height: 1, indent: 70),
                    itemBuilder: (_, i) {
                      final c = chatVM.conversations[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: GestureDetector(
                          onTap: () {
                            chatVM.selectConversation(c.id);
                            setState(() => _selectedConversationId = c.id);
                          },
                          child: Row(
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: c.unreadCount > 0 ? const [Color(0xFFFF4F69), Color(0xFFC76FB6)] : [const Color(0xFFBDC3D4), const Color(0xFF8A91A8)],
                                      ),
                                    ),
                                    child: Center(child: Text(c.participantAvatar, style: theme.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w700))),
                                  ),
                                  if (c.isOnline)
                                    Positioned(right: 2, bottom: 2, child: Container(width: 12, height: 12, decoration: BoxDecoration(color: const Color(0xFF4CAF50), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)))),
                                ],
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(child: Text(c.participantName, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: c.unreadCount > 0 ? FontWeight.w700 : FontWeight.w600, color: const Color(0xFF1A1D2B)))),
                                        Text('2m ago', style: theme.textTheme.bodySmall?.copyWith(color: c.unreadCount > 0 ? const Color(0xFFE94E92) : const Color(0xFF8A91A8), fontWeight: c.unreadCount > 0 ? FontWeight.w600 : FontWeight.w400)),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Expanded(child: Text(c.lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall?.copyWith(color: c.unreadCount > 0 ? const Color(0xFF3A3F52) : const Color(0xFF8A91A8), fontWeight: c.unreadCount > 0 ? FontWeight.w600 : FontWeight.w400))),
                                        if (c.unreadCount > 0) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                            decoration: BoxDecoration(color: const Color(0xFFE94E92), borderRadius: BorderRadius.circular(10)),
                                            child: Text('${c.unreadCount}', style: theme.textTheme.bodySmall?.copyWith(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
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
    );
  }
}

class _ChatDetailView extends StatefulWidget {
  final String conversationId;
  final VoidCallback onBack;

  const _ChatDetailView({required this.conversationId, required this.onBack});

  @override
  State<_ChatDetailView> createState() => _ChatDetailViewState();
}

class _ChatDetailViewState extends State<_ChatDetailView> {
  late TextEditingController _messageCtrl;

  @override
  void initState() {
    super.initState();
    _messageCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _messageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<ChatViewModel>(
      builder: (context, chatVM, _) {
        final conversation =
            chatVM.conversations.firstWhere((c) => c.id == widget.conversationId);
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(onPressed: widget.onBack, icon: const Icon(Icons.arrow_back)),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: [Color(0xFFFF4F69), Color(0xFFC76FB6)])),
                    child: Center(child: Text(conversation.participantAvatar, style: theme.textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w700))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(conversation.participantName, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                        Text(conversation.isOnline ? 'Online' : 'Offline', style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF8A91A8))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: chatVM.currentMessages.length,
                itemBuilder: (context, i) {
                  final msg = chatVM.currentMessages[i];
                  final isMe = msg.senderId == 'me';
                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isMe ? const Color(0xFFE94E92) : const Color(0xFFEDEEF2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(msg.content, style: theme.textTheme.bodySmall?.copyWith(color: isMe ? Colors.white : Colors.black)),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageCtrl,
                      decoration: InputDecoration(
                        hintText: 'Type message...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: Color(0xFFE4E5EA))),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton(
                    mini: true,
                    backgroundColor: const Color(0xFFE94E92),
                    onPressed: () {
                      if (_messageCtrl.text.isNotEmpty) {
                        chatVM.sendMessage(_messageCtrl.text);
                        _messageCtrl.clear();
                      }
                    },
                    child: const Icon(Icons.send, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<AuthViewModel>(
      builder: (context, authVM, _) {
        final user = authVM.currentUser;
        return SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 24),
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(colors: [Color(0xFFFF4F69), Color(0xFFC76FB6)]),
                        boxShadow: [BoxShadow(color: const Color(0xFFE94E92).withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))],
                      ),
                      child: const Icon(Icons.person_rounded, size: 44, color: Colors.white),
                    ),
                    const SizedBox(height: 14),
                    Text(user?.name ?? 'User', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, color: const Color(0xFF1A1D2B))),
                    const SizedBox(height: 4),
                    Text(user?.email ?? 'email@rebuy.pk', style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF8A91A8))),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 3))]),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _StatItem(value: '${user?.itemsListed ?? 0}', label: 'Listed'),
                      Container(width: 1, height: 36, color: const Color(0xFFE4E7EE)),
                      _StatItem(value: '${user?.itemsSold ?? 0}', label: 'Sold'),
                      Container(width: 1, height: 36, color: const Color(0xFFE4E7EE)),
                      _StatItem(value: '${user?.itemsBought ?? 0}', label: 'Bought'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _ProfileMenuItem(
                      icon: Icons.shopping_bag_rounded,
                      label: 'My Ads',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const MyAdsView()),
                        );
                      },
                    ),
                    _ProfileMenuItem(icon: Icons.shopping_bag_outlined, label: 'My Orders'),
                    _ProfileMenuItem(icon: Icons.location_on_outlined, label: 'My Addresses'),
                    _ProfileMenuItem(icon: Icons.payment_outlined, label: 'Payment Methods'),
                    _ProfileMenuItem(icon: Icons.settings_outlined, label: 'Settings'),
                    _ProfileMenuItem(icon: Icons.help_outline_rounded, label: 'Help & Support'),
                    const SizedBox(height: 8),
                    _ProfileMenuItem(
                      icon: Icons.logout_rounded,
                      label: 'Log Out',
                      isDestructive: true,
                      onTap: () async {
                        await authVM.logout();
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, color: const Color(0xFF1A1D2B))),
        const SizedBox(height: 2),
        Text(label, style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF8A91A8))),
      ],
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDestructive;
  final VoidCallback? onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    this.isDestructive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isDestructive ? const Color(0xFFE94E92) : const Color(0xFF3A3F52);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: onTap ?? () {},
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
          child: Row(
            children: [
              Icon(icon, size: 22, color: color),
              const SizedBox(width: 14),
              Expanded(child: Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: color))),
              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}
