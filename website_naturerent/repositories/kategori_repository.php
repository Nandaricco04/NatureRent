<?php
require_once __DIR__ . '/../config/supabase.php';

function getAdminCategories(): array
{
    $categories = fetchCategoryRows();
    $products = fetchCategoryProducts();
    $productCounts = [];

    foreach ($products as $product) {
        $categoryId = (string) ($product['category_id'] ?? '');

        if ($categoryId === '') {
            continue;
        }

        if (!isset($productCounts[$categoryId])) {
            $productCounts[$categoryId] = [
                'total' => 0,
                'active' => 0,
            ];
        }

        $productCounts[$categoryId]['total']++;

        if (categoryProductStock($product) > 0) {
            $productCounts[$categoryId]['active']++;
        }
    }

    return array_map(function (array $category) use ($productCounts): array {
        $categoryId = (string) ($category['id_category'] ?? '');
        $counts = $productCounts[$categoryId] ?? ['total' => 0, 'active' => 0];

        return array_merge($category, [
            '_total_listing' => $counts['total'],
            '_listing_aktif' => $counts['active'],
        ]);
    }, $categories);
}

function getAdminCategoryProducts(): array
{
    $result = supabaseRequest('products?' . http_build_query([
        'select' => 'id_product,name,price_per_day,stock,owner(nama_toko),categories(name)',
        'order' => 'id_product.asc',
    ]));

    return $result['ok'] && is_array($result['data']) ? $result['data'] : [];
}

function fetchCategoryRows(): array
{
    $result = supabaseRequest('categories?' . http_build_query([
        'select' => 'id_category,name',
        'order' => 'id_category.asc',
    ]));

    return $result['ok'] && is_array($result['data']) ? $result['data'] : [];
}

function fetchCategoryProducts(): array
{
    $result = supabaseRequest('products?' . http_build_query([
        'select' => 'id_product,category_id,stock',
    ]));

    return $result['ok'] && is_array($result['data']) ? $result['data'] : [];
}

function categoryProductStock(array $product): int
{
    $stock = $product['stock'] ?? 0;

    return is_numeric($stock) ? (int) $stock : 0;
}

function adminCategoryName(array $category): string
{
    return (string) ($category['name'] ?? '-');
}

function adminCategoryTotalListing(array $category): int
{
    return (int) ($category['_total_listing'] ?? 0);
}

function adminCategoryActiveListing(array $category): int
{
    return (int) ($category['_listing_aktif'] ?? 0);
}

function adminProductName(array $product): string
{
    return (string) ($product['name'] ?? '-');
}

function adminProductStore(array $product): string
{
    return (string) ($product['owner']['nama_toko'] ?? '-');
}

function adminProductCategory(array $product): string
{
    return (string) ($product['categories']['name'] ?? '-');
}

function adminProductPrice(array $product): string
{
    $price = $product['price_per_day'] ?? 0;

    return 'Rp' . number_format((int) $price, 0, ',', '.');
}

function adminProductStock(array $product): int
{
    return categoryProductStock($product);
}
