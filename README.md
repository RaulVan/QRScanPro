# QR Scan Pro

一款功能强大的 iOS 二维码扫描和生成应用。

## 功能特点

### 扫描功能
- 多二维码同时识别
- 智能对焦和曝光控制
- 闪光灯控制
- 点击对焦动画效果
- 相册图片二维码识别

### 生成功能
- 支持多种类型二维码生成
  - 网址链接
  - 电子邮件
  - 联系人信息
  - 电话号码
  - WiFi 配置
  - 文本内容

### 历史记录
- 扫描历史记录
- 生成历史记录
- 分类管理
- 快速复制和分享

## 技术架构

### 项目结构
```
QRScanPro/
├── App/          # 应用程序入口
├── Core/         # 核心功能模块
├── Domain/       # 业务领域模型
├── Data/         # 数据持久化
└── Presentation/ # 用户界面
```

### 技术特点
- SwiftUI + Combine 响应式编程
- MVVM 架构模式
- Core Data 数据持久化
- AVFoundation 相机控制
- Vision 框架图像识别
- Core Image 图像处理

## 系统要求
- iOS 15.0 或更高版本
- Xcode 14.0 或更高版本
- Swift 5.5 或更高版本

## 安装说明

1. 克隆项目
```bash
git clone [repository-url]
```

2. 打开项目
```bash
cd QRScanPro
open QRScanPro.xcodeproj
```

3. 运行项目
- 选择目标设备或模拟器
- 点击运行按钮或按下 `Cmd + R`

## 使用说明

### 扫描二维码
1. 打开应用，默认进入扫描界面
2. 将二维码对准扫描框
3. 自动识别并显示结果
4. 点击屏幕任意位置进行对焦
5. 点击右上角按钮开关闪光灯

### 生成二维码
1. 切换到生成标签页
2. 选择要生成的二维码类型
3. 输入相关信息
4. 点击生成按钮
5. 长按生成的二维码可以保存或分享

## 开发团队
- 开发者：[Your Name]
- 设计师：[Designer Name]

## 版权信息
© 2024 QR Scan Pro. All rights reserved.

---

# QR Scan Pro (English)

A powerful iOS QR code scanning and generation application.

## Features

### Scanning Features
- Multiple QR codes simultaneous recognition
- Smart focus and exposure control
- Flashlight control
- Tap-to-focus with animation
- Photo library QR code recognition

### Generation Features
- Support for multiple QR code types:
  - Website URLs
  - Email addresses
  - Contact information
  - Phone numbers
  - WiFi configurations
  - Text content

### History Management
- Scan history
- Generation history
- Category management
- Quick copy and share

## Technical Architecture

### Project Structure
```
QRScanPro/
├── App/          # Application entry
├── Core/         # Core functionality modules
├── Domain/       # Business domain models
├── Data/         # Data persistence
└── Presentation/ # User interface
```

### Technical Features
- SwiftUI + Combine reactive programming
- MVVM architecture pattern
- Core Data persistence
- AVFoundation camera control
- Vision framework image recognition
- Core Image processing

## System Requirements
- iOS 15.0 or later
- Xcode 14.0 or later
- Swift 5.5 or later

## Installation Guide

1. Clone the project
```bash
git clone [repository-url]
```

2. Open the project
```bash
cd QRScanPro
open QRScanPro.xcodeproj
```

3. Run the project
- Select target device or simulator
- Click run button or press `Cmd + R`

## Usage Instructions

### Scanning QR Codes
1. Open app, default to scanning interface
2. Align QR code with scanning frame
3. Automatic recognition and result display
4. Tap anywhere on screen to focus
5. Tap top-right button to toggle flashlight

### Generating QR Codes
1. Switch to generation tab
2. Select QR code type
3. Enter relevant information
4. Click generate button
5. Long press generated QR code to save or share

## Development Team
- Developer: [Your Name]
- Designer: [Designer Name]

## Copyright
© 2024 QR Scan Pro. All rights reserved. 