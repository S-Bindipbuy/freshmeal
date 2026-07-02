--
-- PostgreSQL database dump
--

\restrict l6OMj7bLpdTdOc0CU3Fo3cs6VBTi2h2IvHidbJMdrHLS1uTTDwzUpxKmBCxzkVe

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
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: freshmeal_user
--

INSERT INTO public.products (id, name, image, description, price, category_id, available, deleted_at, created_at) OVERRIDING SYSTEM VALUE VALUES (2, 'Cambodia coca', '10b15fda-93da-4c6f-9ae8-a59db04b1ced.jpg', NULL, 0.25, 3, true, NULL, '2026-07-02 13:12:00.827839');
INSERT INTO public.products (id, name, image, description, price, category_id, available, deleted_at, created_at) OVERRIDING SYSTEM VALUE VALUES (3, 'Cambodia', '3e228c49-61a8-493e-8422-9973cfb164df.jpg', NULL, 10.00, 3, true, NULL, '2026-07-02 13:14:58.664634');
INSERT INTO public.products (id, name, image, description, price, category_id, available, deleted_at, created_at) OVERRIDING SYSTEM VALUE VALUES (4, 'Hanuman', '441406c2-dd7d-4131-80dc-f2cbb7a146f6.jpg', NULL, 0.50, 4, true, NULL, '2026-07-02 17:45:48.035176');
INSERT INTO public.products (id, name, image, description, price, category_id, available, deleted_at, created_at) OVERRIDING SYSTEM VALUE VALUES (5, 'Angkor', '1d4af68c-d477-4c33-a327-b0c209eb119b.jpg', NULL, 0.60, 4, true, NULL, '2026-07-02 17:47:21.63242');
INSERT INTO public.products (id, name, image, description, price, category_id, available, deleted_at, created_at) OVERRIDING SYSTEM VALUE VALUES (7, 'Teuk Kreung', 'cbca8472-1690-4a15-9a4b-0018e1011443.jpg', NULL, 3.00, 2, true, NULL, '2026-07-02 17:54:46.589612');
INSERT INTO public.products (id, name, image, description, price, category_id, available, deleted_at, created_at) OVERRIDING SYSTEM VALUE VALUES (1, '1', '5a0750d6-b7b0-46b1-bbab-21688414e21d.jpg', '1', 1.00, NULL, true, '2026-07-02 17:55:32.038629', '2026-07-02 13:03:43.406768');
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
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: freshmeal_user
--

INSERT INTO public.users (id, email, name, password_hash, role, avatar, created_at) OVERRIDING SYSTEM VALUE VALUES (1, 'admin@freshmeal.com', 'Admin', '$2a$12$/iS0sL7dKiBJL/fhCdErzeZ6oJ3FRbNFG2BBrnEtreTsdHIquQQQ2', 'admin', '994b8c5b-2532-4843-9e0d-f0b162557e00.jpg', '2026-07-02 13:02:47.960912');


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

\unrestrict l6OMj7bLpdTdOc0CU3Fo3cs6VBTi2h2IvHidbJMdrHLS1uTTDwzUpxKmBCxzkVe

