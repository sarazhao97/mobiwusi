# 分页工具类使用说明

## 概述

这是一个专门为 iOS SwiftUI 应用设计的通用分页工具类，提供了完整的分页功能，包括数据加载、状态管理、错误处理等。

## 文件结构

```
Core/Utils/
├── PaginationManager.swift    # 核心分页管理器
├── PaginationView.swift       # SwiftUI 分页视图组件
├── PaginationExample.swift    # 使用示例
└── README_Pagination.md       # 使用说明（本文件）
```

## 核心功能

### 1. PaginationManager（分页管理器）

- ✅ 通用的分页数据管理
- ✅ 自动处理分页逻辑
- ✅ 支持下拉刷新
- ✅ 支持上拉加载更多
- ✅ 完善的状态管理（空闲、加载中、加载更多、完成、错误）
- ✅ 错误处理和重试机制
- ✅ 可配置的预加载阈值

### 2. PaginationListView（分页列表视图）

- ✅ 开箱即用的 SwiftUI 分页列表
- ✅ 自动显示加载状态
- ✅ 自动显示"没有更多数据"提示
- ✅ 可自定义空数据视图
- ✅ 可自定义错误视图
- ✅ 支持下拉刷新手势

## 快速开始

### 1. 基本使用

```swift
import SwiftUI

struct MyListView: View {
    @StateObject private var paginationManager = PaginationManager<MyDataModel>(
        config: PaginationConfig(pageSize: 20, prefetchThreshold: 5)
    )
    
    var body: some View {
        PaginationListView(paginationManager: paginationManager) { item in
            // 自定义列表项视图
            MyItemView(item: item)
        }
        .onAppear {
            // 设置数据加载器
            paginationManager.loadData = { page, pageSize in
                try await MyNetworkService.fetchData(page: page, pageSize: pageSize)
            }
        }
    }
}
```

### 2. 数据模型要求

你的数据模型需要遵循 `Identifiable` 协议：

```swift
struct MyDataModel: Identifiable, Codable {
    let id: String
    let title: String
    let content: String
}
```

### 3. 网络响应模型

你的网络响应需要遵循 `PaginationResponse` 协议：

```swift
struct MyAPIResponse: PaginationResponse {
    let items: [MyDataModel]
    let hasMore: Bool
    let total: Int
    
    var data: [MyDataModel] { items }
    var hasNextPage: Bool { hasMore }
}
```

## 高级用法

### 1. 自定义空数据视图

```swift
PaginationListView(
    paginationManager: paginationManager,
    content: { item in
        MyItemView(item: item)
    },
    emptyView: {
        VStack {
            Image("empty_icon")
            Text("暂无数据")
        }
    }
)
```

### 2. 自定义错误视图

```swift
PaginationListView(
    paginationManager: paginationManager,
    content: { item in
        MyItemView(item: item)
    },
    errorView: { message, retry in
        VStack {
            Text("加载失败: \(message)")
            Button("重试", action: retry)
        }
    }
)
```

### 3. 手动控制分页

```swift
// 刷新数据
paginationManager.refresh()

// 加载更多
paginationManager.loadMore()

// 重试
paginationManager.retry()

// 清空数据
paginationManager.clear()
```

### 4. 监听状态变化

```swift
paginationManager.onStateChanged = { state in
    switch state {
    case .loading:
        print("正在加载...")
    case .completed:
        print("加载完成")
    case .error(let message):
        print("加载错误: \(message)")
    default:
        break
    }
}
```

## 配置选项

### PaginationConfig

```swift
PaginationConfig(
    pageSize: 20,              // 每页数据量
    initialPage: 1,            // 起始页码
    prefetchThreshold: 5       // 预加载阈值（距离底部多少项时开始加载）
)
```

## 状态说明

- `idle`: 空闲状态
- `loading`: 正在加载（首次加载或刷新）
- `loadingMore`: 正在加载更多
- `completed`: 加载完成（没有更多数据）
- `error(String)`: 加载错误

## 错误处理

工具类提供了三种预定义的错误类型：

- `noDataLoader`: 未设置数据加载器
- `invalidResponse`: 无效的响应数据
- `networkError(String)`: 网络错误

## 最佳实践

1. **合理设置页面大小**: 建议 10-30 条数据，平衡加载速度和用户体验
2. **设置合适的预加载阈值**: 建议 3-5 条，确保流畅的滚动体验
3. **处理网络错误**: 提供友好的错误提示和重试机制
4. **优化列表项性能**: 使用 LazyVStack 和合理的视图结构
5. **内存管理**: 大量数据时考虑实现数据清理机制

## 示例项目

查看 `PaginationExample.swift` 文件获取完整的使用示例，包括：

- 基本列表示例
- 网格布局示例
- 自定义视图示例
- 错误处理示例

## 注意事项

1. 确保数据模型遵循 `Identifiable` 协议
2. 网络响应模型需要遵循 `PaginationResponse` 协议
3. 在 `onAppear` 中设置数据加载器
4. 合理处理异步操作和错误情况
5. 注意内存管理，避免内存泄漏

## 技术支持

如有问题或建议，请联系开发团队。