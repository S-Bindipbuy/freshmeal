--
-- PostgreSQL database dump
--

\restrict w2q1z0tb6eb7vbdr5vYTBmKsVpDrKdThwq7ywP0ntFBzZaIlWcIaYDdmiORMnta

-- Dumped from database version 18.4
-- Dumped by pg_dump version 18.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Data for Name: _sqlx_migrations; Type: TABLE DATA; Schema: public; Owner: freshmeal_user
--

INSERT INTO public._sqlx_migrations (version, description, installed_on, success, checksum, execution_time) VALUES (20260627141551, 'migration', '2026-07-03 01:43:31.605002+07', true, '\x2db038486d8d0e152dfc789e204d1c4f8c60e5041f7f424cdcf8c432402d15a3e94d3f9759ff055284f6aec738cea194', 15836474);
INSERT INTO public._sqlx_migrations (version, description, installed_on, success, checksum, execution_time) VALUES (20260628120000, 'branches', '2026-07-03 01:43:31.622582+07', true, '\xe55c7efc7d9a2ff93d70cee21b63e33dd78ebc65371d02e8d815df34839b2d81f1e9887996d077069abd665b5e8a7166', 4127777);
INSERT INTO public._sqlx_migrations (version, description, installed_on, success, checksum, execution_time) VALUES (20260703000000, 'delivery location', '2026-07-03 01:43:31.628275+07', true, '\x5349124494d3be2d8980f1b6a20a32302f217056fd4c9884a96d75068f52694fa76ab3e2f54614aec1de2d5a25d41615', 2461722);


--
-- Data for Name: branches; Type: TABLE DATA; Schema: public; Owner: freshmeal_user
--

INSERT INTO public.branches (id, name, address, lat, lng, created_at) OVERRIDING SYSTEM VALUE VALUES (1, 'Freshmeal Riverside', '#123 Sisowath Quay, Riverside', 11.5725, 104.9361, '2026-07-02 18:43:31.622582');
INSERT INTO public.branches (id, name, address, lat, lng, created_at) OVERRIDING SYSTEM VALUE VALUES (2, 'Freshmeal BKK', '#456 Norodom Blvd, Boeung Keng Kang', 11.5433, 104.9195, '2026-07-02 18:43:31.622582');
INSERT INTO public.branches (id, name, address, lat, lng, created_at) OVERRIDING SYSTEM VALUE VALUES (3, 'Freshmeal Toul Kork', '#789 Russian Blvd, Toul Kork', 11.5816, 104.9041, '2026-07-02 18:43:31.622582');


--
-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: freshmeal_user
--

INSERT INTO public.categories (id, name, description, created_at) OVERRIDING SYSTEM VALUE VALUES (2, 'Main Dish', 'Main dishes', '2026-07-03 01:43:46.890766');
INSERT INTO public.categories (id, name, description, created_at) OVERRIDING SYSTEM VALUE VALUES (3, 'Beverages', 'Drinks', '2026-07-03 01:43:46.890766');
INSERT INTO public.categories (id, name, description, created_at) OVERRIDING SYSTEM VALUE VALUES (4, 'Beer', 'Beer & alcohol', '2026-07-03 01:43:46.890766');
INSERT INTO public.categories (id, name, description, created_at) OVERRIDING SYSTEM VALUE VALUES (5, 'Drink', NULL, '2026-07-03 01:46:11.14232');
INSERT INTO public.categories (id, name, description, created_at) OVERRIDING SYSTEM VALUE VALUES (6, 'Food', NULL, '2026-07-03 01:46:11.14232');


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: freshmeal_user
--

INSERT INTO public.users (id, email, name, password_hash, role, avatar, created_at) OVERRIDING SYSTEM VALUE VALUES (1, 'admin@freshmeal.com', 'Admin', '$2a$12$/iS0sL7dKiBJL/fhCdErzeZ6oJ3FRbNFG2BBrnEtreTsdHIquQQQ2', 'admin', NULL, '2026-07-02 18:43:31.605002');


--
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: freshmeal_user
--



--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: freshmeal_user
--

INSERT INTO public.products (id, name, image, description, price, category_id, available, deleted_at, created_at) OVERRIDING SYSTEM VALUE VALUES (1, '1', '5a0750d6-b7b0-46b1-bbab-21688414e21d.jpg', '1', 1.00, NULL, true, '2026-07-02 17:55:32.038629', '2026-07-02 13:03:43.406768');
INSERT INTO public.products (id, name, image, description, price, category_id, available, deleted_at, created_at) OVERRIDING SYSTEM VALUE VALUES (2, 'Cambodia coca', '10b15fda-93da-4c6f-9ae8-a59db04b1ced.jpg', NULL, 0.25, 3, true, NULL, '2026-07-02 13:12:00.827839');
INSERT INTO public.products (id, name, image, description, price, category_id, available, deleted_at, created_at) OVERRIDING SYSTEM VALUE VALUES (3, 'Cambodia', '3e228c49-61a8-493e-8422-9973cfb164df.jpg', NULL, 10.00, 3, true, NULL, '2026-07-02 13:14:58.664634');
INSERT INTO public.products (id, name, image, description, price, category_id, available, deleted_at, created_at) OVERRIDING SYSTEM VALUE VALUES (4, 'Hanuman', '441406c2-dd7d-4131-80dc-f2cbb7a146f6.jpg', NULL, 0.50, 4, true, NULL, '2026-07-02 17:45:48.035176');
INSERT INTO public.products (id, name, image, description, price, category_id, available, deleted_at, created_at) OVERRIDING SYSTEM VALUE VALUES (5, 'Angkor', '1d4af68c-d477-4c33-a327-b0c209eb119b.jpg', NULL, 0.60, 4, true, NULL, '2026-07-02 17:47:21.63242');
INSERT INTO public.products (id, name, image, description, price, category_id, available, deleted_at, created_at) OVERRIDING SYSTEM VALUE VALUES (7, 'Teuk Kreung', 'cbca8472-1690-4a15-9a4b-0018e1011443.jpg', NULL, 3.00, 2, true, NULL, '2026-07-02 17:54:46.589612');
INSERT INTO public.products (id, name, image, description, price, category_id, available, deleted_at, created_at) OVERRIDING SYSTEM VALUE VALUES (8, 'Somlor Kari', '3db0db2e-c6a1-42ed-845b-bacbd215793a.jpg', NULL, 1.00, 2, true, NULL, '2026-07-02 17:59:59.544611');
INSERT INTO public.products (id, name, image, description, price, category_id, available, deleted_at, created_at) OVERRIDING SYSTEM VALUE VALUES (9, 'Prohok Ktis', 'e214411f-eaaf-42ef-9810-bd8b273b3fd1.jpg', NULL, 2.50, 2, true, NULL, '2026-07-02 18:02:56.717028');
INSERT INTO public.products (id, name, image, description, price, category_id, available, deleted_at, created_at) OVERRIDING SYSTEM VALUE VALUES (10, 'Somlor Kokoo', '7e92578e-98f7-49fe-ac2c-87cdd2072491.jpg', NULL, 1.00, 2, true, NULL, '2026-07-02 18:06:48.338751');
INSERT INTO public.products (id, name, image, description, price, category_id, available, deleted_at, created_at) OVERRIDING SYSTEM VALUE VALUES (6, 'Amok Khmer', '97182028-141f-4510-b349-cf28f110ee6b.jpg', NULL, 2.50, 2, true, NULL, '2026-07-02 17:52:50.172576');
INSERT INTO public.products (id, name, image, description, price, category_id, available, deleted_at, created_at) OVERRIDING SYSTEM VALUE VALUES (11, 'Bay Srob', '0d72394f-7bfd-4f4c-beca-cb01677b6c3c.jpg', NULL, 1.50, 2, true, NULL, '2026-07-02 18:11:59.88415');
INSERT INTO public.products (id, name, image, description, price, category_id, available, deleted_at, created_at) OVERRIDING SYSTEM VALUE VALUES (12, 'Wurkz', '2ba2b799-d505-4ce7-9196-8f9ddd45e2cb.jpg', NULL, 0.60, 3, true, NULL, '2026-07-02 18:13:48.30216');
INSERT INTO public.products (id, name, image, description, price, category_id, available, deleted_at, created_at) OVERRIDING SYSTEM VALUE VALUES (13, 'IZE Cola', '4ae301ff-3cdc-4b8b-96fe-2b26dc8b3eb8.jpg', NULL, 0.50, 3, true, NULL, '2026-07-02 18:15:09.776674');
INSERT INTO public.products (id, name, image, description, price, category_id, available, deleted_at, created_at) OVERRIDING SYSTEM VALUE VALUES (14, 'Fan TA', '9f1db7b7-0195-4bfe-872c-a50c32e76d04.jpg', NULL, 0.50, 3, true, NULL, '2026-07-02 18:17:12.806771');
INSERT INTO public.products (id, name, image, description, price, category_id, available, deleted_at, created_at) OVERRIDING SYSTEM VALUE VALUES (15, 'Champion', '08e9d362-d5de-405a-9111-207b832798b6.jpg', NULL, 0.50, 3, true, NULL, '2026-07-02 18:18:53.460507');
INSERT INTO public.products (id, name, image, description, price, category_id, available, deleted_at, created_at) OVERRIDING SYSTEM VALUE VALUES (16, 'Boostrong', '2ff62d92-0b86-43a8-82c3-af98d560e72f.jpg', NULL, 0.50, 3, true, NULL, '2026-07-02 18:22:17.944202');
INSERT INTO public.products (id, name, image, description, price, category_id, available, deleted_at, created_at) OVERRIDING SYSTEM VALUE VALUES (17, 'IDOL', 'be85e15d-2c04-4f1e-9075-6f59add1148e.jpg', NULL, 0.50, 3, true, NULL, '2026-07-02 18:27:34.244156');
INSERT INTO public.products (id, name, image, description, price, category_id, available, deleted_at, created_at) OVERRIDING SYSTEM VALUE VALUES (18, 'Cambodia', 'e0dc2bf9-2f12-4d3e-a864-50d91785db42.', NULL, 0.60, 4, true, NULL, '2026-07-02 18:33:28.074429');


--
-- Data for Name: order_items; Type: TABLE DATA; Schema: public; Owner: freshmeal_user
--



--
-- Name: branches_id_seq; Type: SEQUENCE SET; Schema: public; Owner: freshmeal_user
--

SELECT pg_catalog.setval('public.branches_id_seq', 3, true);


--
-- Name: categories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: freshmeal_user
--

SELECT pg_catalog.setval('public.categories_id_seq', 6, true);


--
-- Name: order_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: freshmeal_user
--

SELECT pg_catalog.setval('public.order_items_id_seq', 1, false);


--
-- Name: orders_id_seq; Type: SEQUENCE SET; Schema: public; Owner: freshmeal_user
--

SELECT pg_catalog.setval('public.orders_id_seq', 1, false);


--
-- Name: products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: freshmeal_user
--

SELECT pg_catalog.setval('public.products_id_seq', 18, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: freshmeal_user
--

SELECT pg_catalog.setval('public.users_id_seq', 1, true);


--
-- PostgreSQL database dump complete
--

\unrestrict w2q1z0tb6eb7vbdr5vYTBmKsVpDrKdThwq7ywP0ntFBzZaIlWcIaYDdmiORMnta

