-- Migration number: 0001 	 2025-04-20T00:05:51.000Z
-- نظام إدارة نتائج الطلاب - هيكل قاعدة البيانات

-- حذف الجداول إذا كانت موجودة
DROP TABLE IF EXISTS results;
DROP TABLE IF EXISTS academic_periods;
DROP TABLE IF EXISTS subjects;
DROP TABLE IF EXISTS students;
DROP TABLE IF EXISTS classes;
DROP TABLE IF EXISTS role_permissions;
DROP TABLE IF EXISTS permissions;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS roles;

-- جدول الأدوار (roles)
CREATE TABLE IF NOT EXISTS roles (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  description TEXT,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- جدول المستخدمين (users)
CREATE TABLE IF NOT EXISTS users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  username TEXT UNIQUE NOT NULL,
  password TEXT NOT NULL, -- سيتم تخزينها مشفرة
  name TEXT NOT NULL,
  email TEXT,
  role_id INTEGER NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (role_id) REFERENCES roles(id)
);

-- جدول الصلاحيات (permissions)
CREATE TABLE IF NOT EXISTS permissions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT UNIQUE NOT NULL,
  description TEXT,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- جدول ربط الأدوار بالصلاحيات (role_permissions)
CREATE TABLE IF NOT EXISTS role_permissions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  role_id INTEGER NOT NULL,
  permission_id INTEGER NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (role_id) REFERENCES roles(id),
  FOREIGN KEY (permission_id) REFERENCES permissions(id),
  UNIQUE(role_id, permission_id)
);

-- جدول الصفوف/المراحل (classes)
CREATE TABLE IF NOT EXISTS classes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  description TEXT,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- جدول الطلاب (students)
CREATE TABLE IF NOT EXISTS students (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  full_name TEXT NOT NULL,
  student_id TEXT UNIQUE NOT NULL, -- رقم الجلوس - فريد
  class_id INTEGER NOT NULL,
  birth_date DATE,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (class_id) REFERENCES classes(id)
);

-- جدول المواد الدراسية (subjects)
CREATE TABLE IF NOT EXISTS subjects (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  code TEXT,
  max_score REAL NOT NULL DEFAULT 100,
  min_score REAL NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- جدول الفترات الدراسية (academic_periods)
CREATE TABLE IF NOT EXISTS academic_periods (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  start_date DATE,
  end_date DATE,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- جدول النتائج (results)
CREATE TABLE IF NOT EXISTS results (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  student_id INTEGER NOT NULL,
  subject_id INTEGER NOT NULL,
  academic_period_id INTEGER NOT NULL,
  score REAL NOT NULL,
  grade TEXT, -- التقدير
  created_by INTEGER NOT NULL,
  updated_by INTEGER NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (student_id) REFERENCES students(id),
  FOREIGN KEY (subject_id) REFERENCES subjects(id),
  FOREIGN KEY (academic_period_id) REFERENCES academic_periods(id),
  FOREIGN KEY (created_by) REFERENCES users(id),
  FOREIGN KEY (updated_by) REFERENCES users(id),
  UNIQUE(student_id, subject_id, academic_period_id)
);

-- إنشاء الفهارس (Indexes) لتحسين الأداء
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_role_id ON users(role_id);
CREATE INDEX idx_role_permissions_role_id ON role_permissions(role_id);
CREATE INDEX idx_role_permissions_permission_id ON role_permissions(permission_id);
CREATE INDEX idx_students_student_id ON students(student_id);
CREATE INDEX idx_students_class_id ON students(class_id);
CREATE INDEX idx_results_student_id ON results(student_id);
CREATE INDEX idx_results_subject_id ON results(subject_id);
CREATE INDEX idx_results_academic_period_id ON results(academic_period_id);

-- إدخال البيانات الأولية

-- إدخال الأدوار الافتراضية
INSERT INTO roles (name, description) VALUES 
  ('admin', 'مدير النظام مع صلاحيات كاملة'),
  ('teacher', 'معلم مع صلاحيات محدودة');

-- إدخال المستخدم الافتراضي (مدير النظام)
-- كلمة المرور: 73345 (سيتم تشفيرها في التطبيق)
INSERT INTO users (username, password, name, email, role_id) VALUES 
  ('alredfani', '$2b$10$XFE0UPBzBed.UwQQCt.pfOECfLQdw9xzLo8ewnM.mLPVbKeVaqZMO', 'مدير النظام', 'admin@example.com', 1);

-- إدخال الصلاحيات الأساسية
INSERT INTO permissions (name, description) VALUES 
  ('manage_users', 'إدارة المستخدمين'),
  ('manage_students', 'إدارة الطلاب'),
  ('manage_subjects', 'إدارة المواد الدراسية'),
  ('manage_classes', 'إدارة الصفوف'),
  ('manage_periods', 'إدارة الفترات الدراسية'),
  ('manage_results', 'إدارة النتائج'),
  ('view_results', 'عرض النتائج');

-- ربط الأدوار بالصلاحيات
-- مدير النظام له جميع الصلاحيات
INSERT INTO role_permissions (role_id, permission_id) VALUES 
  (1, 1), (1, 2), (1, 3), (1, 4), (1, 5), (1, 6), (1, 7);
  
-- المعلم له صلاحيات محدودة
INSERT INTO role_permissions (role_id, permission_id) VALUES 
  (2, 6), (2, 7);

-- إدخال بعض الصفوف للاختبار
INSERT INTO classes (name, description) VALUES 
  ('الصف الأول', 'الصف الأول الثانوي'),
  ('الصف الثاني', 'الصف الثاني الثانوي'),
  ('الصف الثالث', 'الصف الثالث الثانوي');

-- إدخال بعض المواد الدراسية للاختبار
INSERT INTO subjects (name, code, max_score, min_score) VALUES 
  ('اللغة العربية', 'ARB101', 100, 0),
  ('اللغة الإنجليزية', 'ENG101', 100, 0),
  ('الرياضيات', 'MATH101', 100, 0),
  ('العلوم', 'SCI101', 100, 0),
  ('التاريخ', 'HIST101', 100, 0),
  ('الجغرافيا', 'GEO101', 100, 0);

-- إدخال فترة دراسية للاختبار
INSERT INTO academic_periods (name, start_date, end_date) VALUES 
  ('الفصل الدراسي الأول 2024-2025', '2024-09-01', '2024-12-31'),
  ('الفصل الدراسي الثاني 2024-2025', '2025-01-01', '2025-05-31');
