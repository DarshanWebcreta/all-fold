# Developer Rules & Coding Standards

To maintain code quality, clean architecture, and modularity in the ALLFOLD project, all developers and AI assistants must follow these standards.

## 1. Directory Structure & MVC Pattern
We follow the GetX-based MVC (Model-View-Controller) design pattern:
- **Model**: Data structures and serialization logic, located in `lib/featute/<feature_name>/model/`
- **View/Presentation**: UI screens and views, located in `lib/featute/<feature_name>/presentation/`
- **Controller**: Business logic and state management, located in `lib/featute/<feature_name>/controller/`

## 2. Frontend File Size Limit (Max 150 Lines)
- Frontend screen/view files must be kept clean and concise, with a **maximum limit of 150 lines of code**.
- If a screen is growing beyond 150 lines, extract individual sub-sections or elements into separate widget classes in a feature-wise `widget` folder, e.g.:
  `lib/featute/<feature_name>/presentation/widget/`

## 3. Code Reuse & Component Promotion
- Do not write extra/duplicate code. Always try to reuse widgets.
- If a widget is used across multiple screens or features, promote it to the core component folder:
  `lib/core/component/`

## 4. State Management
- Utilize GetX controllers for reactive state tracking (`Rx` variables, `obx`, etc.).
- Keep business logic and API requests out of the view layer; delegate them entirely to controllers.
