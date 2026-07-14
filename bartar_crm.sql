--
-- PostgreSQL database dump
--

\restrict GKfU85ZpqdAuJaQgj1dQOqAjBnvWWV6YkwYxwna0vvxndJ21nwJdMgBwDVXtNqo

-- Dumped from database version 16.13
-- Dumped by pg_dump version 16.13

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: PartQuality; Type: TYPE; Schema: public; Owner: bartar_user
--

CREATE TYPE public."PartQuality" AS ENUM (
    'ORIGINAL',
    'HIGH_COPY',
    'COPY'
);


ALTER TYPE public."PartQuality" OWNER TO bartar_user;

--
-- Name: PartRequestStatus; Type: TYPE; Schema: public; Owner: bartar_user
--

CREATE TYPE public."PartRequestStatus" AS ENUM (
    'CREATED',
    'WAITING_CUSTOMER',
    'APPROVED',
    'REJECTED',
    'WAITING_PURCHASE',
    'PURCHASING',
    'PURCHASED',
    'NOT_FOUND',
    'DELIVERED',
    'RETURNED',
    'CONSUMED',
    'CLOSED',
    'CANCELLED'
);


ALTER TYPE public."PartRequestStatus" OWNER TO bartar_user;

--
-- Name: PriceType; Type: TYPE; Schema: public; Owner: bartar_user
--

CREATE TYPE public."PriceType" AS ENUM (
    'BUY',
    'SELL'
);


ALTER TYPE public."PriceType" OWNER TO bartar_user;

--
-- Name: RepairTicketStatus; Type: TYPE; Schema: public; Owner: bartar_user
--

CREATE TYPE public."RepairTicketStatus" AS ENUM (
    'OPEN',
    'IN_PROGRESS',
    'DELIVERED',
    'CLOSED',
    'CANCELLED'
);


ALTER TYPE public."RepairTicketStatus" OWNER TO bartar_user;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: _prisma_migrations; Type: TABLE; Schema: public; Owner: bartar_user
--

CREATE TABLE public._prisma_migrations (
    id character varying(36) NOT NULL,
    checksum character varying(64) NOT NULL,
    finished_at timestamp with time zone,
    migration_name character varying(255) NOT NULL,
    logs text,
    rolled_back_at timestamp with time zone,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    applied_steps_count integer DEFAULT 0 NOT NULL
);


ALTER TABLE public._prisma_migrations OWNER TO bartar_user;

--
-- Name: activity_logs; Type: TABLE; Schema: public; Owner: bartar_user
--

CREATE TABLE public.activity_logs (
    id text NOT NULL,
    "userId" text NOT NULL,
    action text NOT NULL,
    "entityType" text NOT NULL,
    "entityId" text NOT NULL,
    "previousValue" jsonb,
    "newValue" jsonb,
    ip text,
    device text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.activity_logs OWNER TO bartar_user;

--
-- Name: attachments; Type: TABLE; Schema: public; Owner: bartar_user
--

CREATE TABLE public.attachments (
    id text NOT NULL,
    "partRequestId" text NOT NULL,
    "fileUrl" text NOT NULL,
    "fileName" text NOT NULL,
    "mimeType" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "deletedAt" timestamp(3) without time zone
);


ALTER TABLE public.attachments OWNER TO bartar_user;

--
-- Name: brands; Type: TABLE; Schema: public; Owner: bartar_user
--

CREATE TABLE public.brands (
    id text NOT NULL,
    name text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.brands OWNER TO bartar_user;

--
-- Name: customers; Type: TABLE; Schema: public; Owner: bartar_user
--

CREATE TABLE public.customers (
    id text NOT NULL,
    name text NOT NULL,
    phone text NOT NULL,
    "secondaryPhone" text,
    address text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "deletedAt" timestamp(3) without time zone
);


ALTER TABLE public.customers OWNER TO bartar_user;

--
-- Name: device_models; Type: TABLE; Schema: public; Owner: bartar_user
--

CREATE TABLE public.device_models (
    id text NOT NULL,
    name text NOT NULL,
    "brandId" text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "deviceTypeId" text
);


ALTER TABLE public.device_models OWNER TO bartar_user;

--
-- Name: device_types; Type: TABLE; Schema: public; Owner: bartar_user
--

CREATE TABLE public.device_types (
    id text NOT NULL,
    name text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.device_types OWNER TO bartar_user;

--
-- Name: devices; Type: TABLE; Schema: public; Owner: bartar_user
--

CREATE TABLE public.devices (
    id text NOT NULL,
    "brandId" text NOT NULL,
    "modelId" text NOT NULL,
    serial text,
    imei text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "deletedAt" timestamp(3) without time zone
);


ALTER TABLE public.devices OWNER TO bartar_user;

--
-- Name: notifications; Type: TABLE; Schema: public; Owner: bartar_user
--

CREATE TABLE public.notifications (
    id text NOT NULL,
    "userId" text NOT NULL,
    title text NOT NULL,
    message text NOT NULL,
    "isRead" boolean DEFAULT false NOT NULL,
    type text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.notifications OWNER TO bartar_user;

--
-- Name: part_prices; Type: TABLE; Schema: public; Owner: bartar_user
--

CREATE TABLE public.part_prices (
    id text NOT NULL,
    "modelId" text NOT NULL,
    "partId" text NOT NULL,
    quality public."PartQuality" NOT NULL,
    "buyPrice" integer,
    "sellPrice" integer,
    "needsReview" boolean DEFAULT false NOT NULL,
    notes text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.part_prices OWNER TO bartar_user;

--
-- Name: part_requests; Type: TABLE; Schema: public; Owner: bartar_user
--

CREATE TABLE public.part_requests (
    id text NOT NULL,
    "repairTicketId" text,
    "partId" text NOT NULL,
    quality public."PartQuality" NOT NULL,
    brand text,
    model text,
    status public."PartRequestStatus" DEFAULT 'CREATED'::public."PartRequestStatus" NOT NULL,
    "announcedPrice" integer,
    "depositAmount" integer DEFAULT 0 NOT NULL,
    "isTest" boolean DEFAULT false NOT NULL,
    description text,
    "createdById" text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "deletedAt" timestamp(3) without time zone,
    quantity integer DEFAULT 1 NOT NULL,
    "receptionNumber" text NOT NULL,
    "modelId" text
);


ALTER TABLE public.part_requests OWNER TO bartar_user;

--
-- Name: parts; Type: TABLE; Schema: public; Owner: bartar_user
--

CREATE TABLE public.parts (
    id text NOT NULL,
    name text NOT NULL,
    category text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "deletedAt" timestamp(3) without time zone
);


ALTER TABLE public.parts OWNER TO bartar_user;

--
-- Name: permissions; Type: TABLE; Schema: public; Owner: bartar_user
--

CREATE TABLE public.permissions (
    id text NOT NULL,
    code text NOT NULL,
    "group" text NOT NULL,
    description text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.permissions OWNER TO bartar_user;

--
-- Name: price_histories; Type: TABLE; Schema: public; Owner: bartar_user
--

CREATE TABLE public.price_histories (
    id text NOT NULL,
    "partId" text NOT NULL,
    "purchaseId" text,
    type public."PriceType" DEFAULT 'BUY'::public."PriceType" NOT NULL,
    price integer NOT NULL,
    "recordedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "modelId" text,
    quality public."PartQuality"
);


ALTER TABLE public.price_histories OWNER TO bartar_user;

--
-- Name: purchases; Type: TABLE; Schema: public; Owner: bartar_user
--

CREATE TABLE public.purchases (
    id text NOT NULL,
    "partRequestId" text NOT NULL,
    "vendorId" text NOT NULL,
    price integer NOT NULL,
    description text,
    "buyerId" text NOT NULL,
    "purchasedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "isReturned" boolean DEFAULT false NOT NULL,
    "returnedAt" timestamp(3) without time zone,
    "returnReason" text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL
);


ALTER TABLE public.purchases OWNER TO bartar_user;

--
-- Name: repair_tickets; Type: TABLE; Schema: public; Owner: bartar_user
--

CREATE TABLE public.repair_tickets (
    id text NOT NULL,
    "ticketNumber" text NOT NULL,
    "customerId" text NOT NULL,
    "deviceId" text NOT NULL,
    status public."RepairTicketStatus" DEFAULT 'OPEN'::public."RepairTicketStatus" NOT NULL,
    "createdById" text NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "deletedAt" timestamp(3) without time zone,
    "issueDescription" text
);


ALTER TABLE public.repair_tickets OWNER TO bartar_user;

--
-- Name: role_permissions; Type: TABLE; Schema: public; Owner: bartar_user
--

CREATE TABLE public.role_permissions (
    "roleId" text NOT NULL,
    "permissionId" text NOT NULL,
    "assignedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.role_permissions OWNER TO bartar_user;

--
-- Name: roles; Type: TABLE; Schema: public; Owner: bartar_user
--

CREATE TABLE public.roles (
    id text NOT NULL,
    name text NOT NULL,
    description text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "deletedAt" timestamp(3) without time zone
);


ALTER TABLE public.roles OWNER TO bartar_user;

--
-- Name: sessions; Type: TABLE; Schema: public; Owner: bartar_user
--

CREATE TABLE public.sessions (
    id text NOT NULL,
    "userId" text NOT NULL,
    "tokenHash" text NOT NULL,
    "userAgent" text,
    ip text,
    "expiresAt" timestamp(3) without time zone NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.sessions OWNER TO bartar_user;

--
-- Name: status_histories; Type: TABLE; Schema: public; Owner: bartar_user
--

CREATE TABLE public.status_histories (
    id text NOT NULL,
    "partRequestId" text NOT NULL,
    "previousStatus" public."PartRequestStatus",
    "newStatus" public."PartRequestStatus" NOT NULL,
    "changedById" text NOT NULL,
    description text,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.status_histories OWNER TO bartar_user;

--
-- Name: user_roles; Type: TABLE; Schema: public; Owner: bartar_user
--

CREATE TABLE public.user_roles (
    "userId" text NOT NULL,
    "roleId" text NOT NULL,
    "assignedAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.user_roles OWNER TO bartar_user;

--
-- Name: users; Type: TABLE; Schema: public; Owner: bartar_user
--

CREATE TABLE public.users (
    id text NOT NULL,
    name text NOT NULL,
    phone text NOT NULL,
    email text,
    "passwordHash" text NOT NULL,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "deletedAt" timestamp(3) without time zone
);


ALTER TABLE public.users OWNER TO bartar_user;

--
-- Name: vendors; Type: TABLE; Schema: public; Owner: bartar_user
--

CREATE TABLE public.vendors (
    id text NOT NULL,
    name text NOT NULL,
    phone text,
    address text,
    "isActive" boolean DEFAULT true NOT NULL,
    "createdAt" timestamp(3) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "updatedAt" timestamp(3) without time zone NOT NULL,
    "deletedAt" timestamp(3) without time zone
);


ALTER TABLE public.vendors OWNER TO bartar_user;

--
-- Data for Name: _prisma_migrations; Type: TABLE DATA; Schema: public; Owner: bartar_user
--

COPY public._prisma_migrations (id, checksum, finished_at, migration_name, logs, rolled_back_at, started_at, applied_steps_count) FROM stdin;
93e97a67-cd13-4ab6-ad65-864c25550002	337a445784dfd13bd71ca9a98ea45969ab6b9a406ff14984c94e4fd2256c11a2	2026-07-13 08:39:30.931268+00	20260713083930_init	\N	\N	2026-07-13 08:39:30.486534+00	1
b9647ee0-5221-4958-b60d-4072bd936a87	8a23cfec920bc77fe99475e4e89956dab9b6b204aef06db48cc2d3ae38a149d2	2026-07-13 08:45:51.09041+00	20260713084551_add_sessions	\N	\N	2026-07-13 08:45:51.04917+00	1
61b912ed-8a85-4ba9-b935-2c19a263d316	bcaadcf438050533565cedd2c684c0b8cfbeab7e89b7cc11f7d7ef60fceb0ad2	2026-07-13 22:12:08.624907+00	20260713221208_add_issue_description_to_repair_ticket	\N	\N	2026-07-13 22:12:08.614157+00	1
81d677e1-96a1-4c53-8831-4b34f51352b2	86cfcc9773af4115811bf178a546cafdd7c29206dfe312d1fc8a01495750d30a	2026-07-13 22:38:53.080035+00	20260713223853_decouple_part_request_from_ticket	\N	\N	2026-07-13 22:38:53.04395+00	1
ed5d2edb-85c0-47f5-ac47-fd69d3e32847	5d3ddae8fa273c68dd3eb9f8b1dd8fc0c28041565d5feac3a947b45b5d60de54	2026-07-14 07:02:31.316772+00	20260714070231_pricing_taxonomy	\N	\N	2026-07-14 07:02:31.212379+00	1
\.


--
-- Data for Name: activity_logs; Type: TABLE DATA; Schema: public; Owner: bartar_user
--

COPY public.activity_logs (id, "userId", action, "entityType", "entityId", "previousValue", "newValue", ip, device, "createdAt") FROM stdin;
cmrj54wr10003so8zaehd3ura	cmrizjjwb0019gmio8se0jmba	LOGIN	User	cmrizjjwb0019gmio8se0jmba	\N	\N	::1	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	2026-07-13 11:30:17.678
cmrj5k7dc0003bvev944oa3rk	cmrizjjwb0019gmio8se0jmba	LOGIN	User	cmrizjjwb0019gmio8se0jmba	\N	\N	::1	curl/8.5.0	2026-07-13 11:42:11.28
cmrj5mb970006bvevwk6b112u	cmrizjjwb0019gmio8se0jmba	LOGOUT	User	cmrizjjwb0019gmio8se0jmba	\N	\N	::1	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	2026-07-13 11:43:49.627
cmrj5mdxh000abvevn5w0274g	cmrizjjwb0019gmio8se0jmba	LOGIN	User	cmrizjjwb0019gmio8se0jmba	\N	\N	::1	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	2026-07-13 11:43:53.093
cmrjgnmzl0002imy3v6sobx84	cmrizjjwb0019gmio8se0jmba	CREATE_USER	User	cmrjgnmzd0000imy3xvld7io7	\N	{"name": "علی تعمیرکار", "phone": "09121111111", "roleIds": ["cmrizjj6z0015gmio7aahjhph"]}	::1	curl/8.5.0	2026-07-13 16:52:47.266
cmrjho2jx0002z075qanrrei8	cmrizjjwb0019gmio8se0jmba	CREATE_USER	User	cmrjho2jn0000z0759oo3jog3	\N	{"name": "مهدی رحیمی", "phone": "09916352600", "roleIds": ["cmrizjj4t0014gmiou2mfq2lq", "cmrizjj840016gmio73nyvk8i", "cmrizjjb40017gmioqjt8s7j0"]}	::1	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	2026-07-13 17:21:07.053
cmrjhp1tx0006z075qyp2rlca	cmrjho2jn0000z0759oo3jog3	LOGIN	User	cmrjho2jn0000z0759oo3jog3	\N	\N	::1	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	2026-07-13 17:21:52.773
cmrjmmvv70003kx82ojkvech3	cmrizjjwb0019gmio8se0jmba	LOGIN	User	cmrizjjwb0019gmio8se0jmba	\N	\N	::1	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	2026-07-13 19:40:09.811
cmrjt28go0006jgwx3iu6jepz	cmrizjjwb0019gmio8se0jmba	CREATE_PART_REQUEST	PartRequest	cmrjt28fl0002jgwxknfyfhwt	\N	{"part": "ببب", "quality": "ORIGINAL", "quantity": 1, "announcedPrice": null, "receptionNumber": "544545"}	::1	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	2026-07-13 22:40:03.672
cmrjt2vf6000ajgwxfqc7vsby	cmrizjjwb0019gmio8se0jmba	CHANGE_STATUS	PartRequest	cmrjt28fl0002jgwxknfyfhwt	{"status": "CREATED"}	{"price": 4000000, "action": "ANNOUNCE_PRICE", "status": "WAITING_CUSTOMER"}	::1	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	2026-07-13 22:40:33.426
cmrjt35mn000gjgwxcemvl83v	cmrizjjwb0019gmio8se0jmba	CHANGE_STATUS	PartRequest	cmrjt28fl0002jgwxknfyfhwt	{"status": "WAITING_CUSTOMER"}	{"price": null, "action": "APPROVE", "status": "WAITING_PURCHASE"}	::1	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	2026-07-13 22:40:46.655
cmrjt3bjc000kjgwxff480c57	cmrizjjwb0019gmio8se0jmba	CHANGE_STATUS	PartRequest	cmrjt28fl0002jgwxknfyfhwt	{"status": "WAITING_PURCHASE"}	{"price": null, "action": "START_PURCHASE", "status": "PURCHASING"}	::1	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	2026-07-13 22:40:54.312
cmrkbazcp0009mneopc2yvfgz	cmrizjjwb0019gmio8se0jmba	CREATE_REPAIR	RepairTicket	cmrkbazce0007mneornfl6o64	\N	{"brand": "Samsung", "model": "Galaxy A52", "customerId": "cmrkbazbs0000mneo22n4wdvz", "ticketNumber": "1001"}	::1	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	2026-07-14 07:10:44.857
cmrkbbzlt000imneop0jotspa	cmrizjjwb0019gmio8se0jmba	CREATE_PART_REQUEST	PartRequest	cmrkbbzk9000cmneoxa5m6wyp	\N	{"part": "باتری", "quality": "ORIGINAL", "quantity": 1, "announcedPrice": 25000000, "receptionNumber": "10548"}	::1	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	2026-07-14 07:11:31.841
cmrkbc6gk000omneoc1uai58f	cmrizjjwb0019gmio8se0jmba	CHANGE_STATUS	PartRequest	cmrkbbzk9000cmneoxa5m6wyp	{"status": "WAITING_CUSTOMER"}	{"price": null, "action": "APPROVE", "status": "WAITING_PURCHASE"}	::1	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	2026-07-14 07:11:40.724
cmrkbc9o3000smneo46ksmis5	cmrizjjwb0019gmio8se0jmba	CHANGE_STATUS	PartRequest	cmrkbbzk9000cmneoxa5m6wyp	{"status": "WAITING_PURCHASE"}	{"price": null, "action": "START_PURCHASE", "status": "PURCHASING"}	::1	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	2026-07-14 07:11:44.883
cmrkbsj7b0008v0qqn7r0kt7f	cmrizjjwb0019gmio8se0jmba	CREATE_PART_REQUEST	PartRequest	cmrkbsj5r0002v0qq19kkmynj	\N	{"part": "ال سی دی", "quality": "ORIGINAL", "quantity": 1, "announcedPrice": 52000000, "receptionNumber": "5812"}	::1	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	2026-07-14 07:24:23.735
cmrkbsqwt000ev0qqw7srlr30	cmrizjjwb0019gmio8se0jmba	CHANGE_STATUS	PartRequest	cmrkbsj5r0002v0qq19kkmynj	{"status": "WAITING_CUSTOMER"}	{"price": null, "action": "APPROVE", "status": "WAITING_PURCHASE"}	::1	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	2026-07-14 07:24:33.725
cmrkbstsr000iv0qq4hdoeiqo	cmrizjjwb0019gmio8se0jmba	CHANGE_STATUS	PartRequest	cmrkbsj5r0002v0qq19kkmynj	{"status": "WAITING_PURCHASE"}	{"price": null, "action": "START_PURCHASE", "status": "PURCHASING"}	::1	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	2026-07-14 07:24:37.467
cmrkbu7ri000lv0qqfdodtt00	cmrizjjwb0019gmio8se0jmba	CREATE_VENDOR	Vendor	cmrkbu7ra000jv0qqk4pc55f8	\N	{"name": "موبایل ستاک"}	::1	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	2026-07-14 07:25:42.222
cmrkbu7wm000xv0qqzbl850w7	cmrizjjwb0019gmio8se0jmba	EDIT_PRICE	PartPrice	cmrkbazc30003mneojccqn9zn:cmrkbsj4y0000v0qqw5o886a9:ORIGINAL	\N	{"source": "AUTO_ON_PURCHASE", "buyPrice": 48000000, "sellPrice": 62400000, "needsReview": true}	::1	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	2026-07-14 07:25:42.406
cmrkbu7ws000zv0qqauor913c	cmrizjjwb0019gmio8se0jmba	REGISTER_PURCHASE	Purchase	cmrkbu7rs000nv0qqufs79xrn	\N	{"price": 48000000, "vendorId": "cmrkbu7ra000jv0qqk4pc55f8", "partRequestId": "cmrkbsj5r0002v0qq19kkmynj", "announcedPrice": 52000000, "receptionNumber": "5812"}	::1	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	2026-07-14 07:25:42.412
cmrkbwfxt0013v0qqlq2fptdk	cmrizjjwb0019gmio8se0jmba	RETURN_PURCHASE	Purchase	cmrkbu7rs000nv0qqufs79xrn	{"isReturned": false}	{"reason": "ایراد داشت", "isReturned": true}	::1	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	2026-07-14 07:27:26.13
cmrkbxs7q0017v0qq83ez2k7u	cmrizjjwb0019gmio8se0jmba	CREATE_MODEL	DeviceModel	cmrkbxs700015v0qqtfqefy5a	\N	{"name": "a16", "brand": "Samsung", "deviceType": "موبایل"}	::1	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	2026-07-14 07:28:28.694
cmrkbxsek001gv0qq5ul3rdxx	cmrizjjwb0019gmio8se0jmba	CREATE_PART_REQUEST	PartRequest	cmrkbxse1001av0qq2iwql35v	\N	{"part": "ال سی دی", "quality": "ORIGINAL", "quantity": 1, "announcedPrice": 8000000, "receptionNumber": "2512"}	::1	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	2026-07-14 07:28:28.94
cmrkbxx98001mv0qqus7k1qdq	cmrizjjwb0019gmio8se0jmba	CHANGE_STATUS	PartRequest	cmrkbxse1001av0qq2iwql35v	{"status": "WAITING_CUSTOMER"}	{"price": null, "action": "APPROVE", "status": "WAITING_PURCHASE"}	::1	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	2026-07-14 07:28:35.228
cmrkby2o7001qv0qqvrm8afss	cmrizjjwb0019gmio8se0jmba	CHANGE_STATUS	PartRequest	cmrkbxse1001av0qq2iwql35v	{"status": "WAITING_PURCHASE"}	{"price": null, "action": "START_PURCHASE", "status": "PURCHASING"}	::1	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	2026-07-14 07:28:42.247
cmrkbyflt0022v0qq8l9xy1bj	cmrizjjwb0019gmio8se0jmba	EDIT_PRICE	PartPrice	cmrkbxs700015v0qqtfqefy5a:cmrkbsj4y0000v0qqw5o886a9:ORIGINAL	\N	{"source": "AUTO_ON_PURCHASE", "buyPrice": 9000000, "sellPrice": 11700000, "needsReview": true}	::1	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	2026-07-14 07:28:59.009
cmrkbyfm00024v0qq797gmvhh	cmrizjjwb0019gmio8se0jmba	REGISTER_PURCHASE	Purchase	cmrkbyfiy001sv0qqjiresexo	\N	{"price": 9000000, "vendorId": "cmrkbu7ra000jv0qqk4pc55f8", "partRequestId": "cmrkbxse1001av0qq2iwql35v", "announcedPrice": 8000000, "receptionNumber": "2512"}	::1	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	2026-07-14 07:28:59.016
cmrkcpini002dv0qq0m2olrz4	cmrizjjwb0019gmio8se0jmba	CREATE_PART_REQUEST	PartRequest	cmrkcpilv0027v0qqsgolo27p	\N	{"part": "باتری", "quality": "ORIGINAL", "quantity": 1, "announcedPrice": 2600000, "receptionNumber": "5023"}	::1	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	2026-07-14 07:50:02.67
cmrkcps32002jv0qq3r8wuenb	cmrizjjwb0019gmio8se0jmba	CHANGE_STATUS	PartRequest	cmrkcpilv0027v0qqsgolo27p	{"status": "WAITING_CUSTOMER"}	{"price": null, "action": "APPROVE", "status": "WAITING_PURCHASE"}	::1	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	2026-07-14 07:50:14.894
cmrkcr0cu002sv0qq17mvw0dj	cmrizjjwb0019gmio8se0jmba	CREATE_PART_REQUEST	PartRequest	cmrkcr0bd002mv0qq0rvkqnhz	\N	{"part": "ال سی دی", "quality": "ORIGINAL", "quantity": 1, "announcedPrice": 5000000, "receptionNumber": "2056"}	::1	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	2026-07-14 07:51:12.27
cmrkcr6gz002yv0qqo4dm1t2o	cmrizjjwb0019gmio8se0jmba	CHANGE_STATUS	PartRequest	cmrkcr0bd002mv0qq0rvkqnhz	{"status": "WAITING_CUSTOMER"}	{"price": null, "action": "APPROVE", "status": "WAITING_PURCHASE"}	::1	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	2026-07-14 07:51:20.195
cmrkcslyp0031v0qqbrsvlrbd	cmrizjjwb0019gmio8se0jmba	CREATE_VENDOR	Vendor	cmrkcslyh002zv0qqwb1ku8xp	\N	{"name": "jhdhd"}	::1	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	2026-07-14 07:52:26.929
cmrkcsm1m003fv0qqnsmskpo7	cmrizjjwb0019gmio8se0jmba	EDIT_PRICE	PartPrice	cmrkbxs700015v0qqtfqefy5a:cmrkbsj4y0000v0qqw5o886a9:ORIGINAL	{"buyPrice": 9000000, "sellPrice": 11700000}	{"source": "AUTO_ON_PURCHASE", "buyPrice": 6000000, "sellPrice": 7800000, "needsReview": false}	::1	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	2026-07-14 07:52:27.035
cmrkcsm1s003hv0qqj1q56cza	cmrizjjwb0019gmio8se0jmba	REGISTER_PURCHASE	Purchase	cmrkcslyv0033v0qqqqoej985	\N	{"price": 6000000, "vendorId": "cmrkcslyh002zv0qqwb1ku8xp", "partRequestId": "cmrkcr0bd002mv0qq0rvkqnhz", "announcedPrice": 5000000, "receptionNumber": "2056"}	::1	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	2026-07-14 07:52:27.04
cmrkct21o003lv0qq3usewpf5	cmrizjjwb0019gmio8se0jmba	RETURN_PURCHASE	Purchase	cmrkcslyv0033v0qqqqoej985	{"isReturned": false}	{"reason": "hjf", "isReturned": true}	::1	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	2026-07-14 07:52:47.772
cmrkr38fy0003x2yl2noqjmsh	cmrizjjwb0019gmio8se0jmba	LOGIN	User	cmrizjjwb0019gmio8se0jmba	\N	\N	::ffff:127.0.0.1	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:152.0) Gecko/20100101 Firefox/152.0	2026-07-14 14:32:37.246
\.


--
-- Data for Name: attachments; Type: TABLE DATA; Schema: public; Owner: bartar_user
--

COPY public.attachments (id, "partRequestId", "fileUrl", "fileName", "mimeType", "createdAt", "deletedAt") FROM stdin;
\.


--
-- Data for Name: brands; Type: TABLE DATA; Schema: public; Owner: bartar_user
--

COPY public.brands (id, name, "createdAt", "updatedAt") FROM stdin;
cmrkbazbx0001mneo2r1y2f90	Samsung	2026-07-14 07:10:44.829	2026-07-14 07:10:44.829
cmrknujy4000h4hlefueee7c4	سرفیس	2026-07-14 13:01:53.404	2026-07-14 13:01:53.404
cmrknujyb000i4hleung9zde3	ایسوس	2026-07-14 13:01:53.411	2026-07-14 13:01:53.411
cmrknujyf000j4hle46icumbs	ای یی تل	2026-07-14 13:01:53.415	2026-07-14 13:01:53.415
cmrknujyi000k4hlex5dukjd6	بلک بری	2026-07-14 13:01:53.418	2026-07-14 13:01:53.418
cmrknujyl000l4hlezisknz7b	سونی	2026-07-14 13:01:53.421	2026-07-14 13:01:53.421
cmrknujyo000m4hlecl948w9e	آنر	2026-07-14 13:01:53.424	2026-07-14 13:01:53.424
cmrknujys000n4hlezjygamno	فوجیتسو	2026-07-14 13:01:53.429	2026-07-14 13:01:53.429
cmrknujyw000o4hlee6zipn1g	وکال	2026-07-14 13:01:53.432	2026-07-14 13:01:53.432
cmrknujyz000p4hley4g9fw4c	SOUNDPEATS	2026-07-14 13:01:53.435	2026-07-14 13:01:53.435
cmrknujz2000q4hle3l02mekk	کت	2026-07-14 13:01:53.438	2026-07-14 13:01:53.438
cmrknujz5000r4hleshjq47jw	موتورولا	2026-07-14 13:01:53.441	2026-07-14 13:01:53.441
cmrknujz9000s4hleu8mshqu7	ام اس آی	2026-07-14 13:01:53.445	2026-07-14 13:01:53.445
cmrknujzd000t4hle1ujh33no	دل	2026-07-14 13:01:53.449	2026-07-14 13:01:53.449
cmrknujzi000u4hle2av7btwx	هواوی	2026-07-14 13:01:53.454	2026-07-14 13:01:53.454
cmrknujzl000v4hle1n0o4b2k	ویوو	2026-07-14 13:01:53.457	2026-07-14 13:01:53.457
cmrknujzo000w4hlesj7fng18	اپل	2026-07-14 13:01:53.461	2026-07-14 13:01:53.461
cmrknujzs000x4hlebzvywl20	Helios 300	2026-07-14 13:01:53.464	2026-07-14 13:01:53.464
cmrknujzv000y4hle1u0ywsym	شیائومی	2026-07-14 13:01:53.467	2026-07-14 13:01:53.467
cmrknujzy000z4hlef0vui8me	اچ تی سی	2026-07-14 13:01:53.47	2026-07-14 13:01:53.47
cmrknuk0100104hle0biwkdw8	گلوریمی	2026-07-14 13:01:53.473	2026-07-14 13:01:53.473
cmrknuk0500114hleha2g5pf3	ایسر	2026-07-14 13:01:53.478	2026-07-14 13:01:53.478
cmrknuk0900124hled5cyqa39	مک بوک	2026-07-14 13:01:53.481	2026-07-14 13:01:53.481
cmrknuk0b00134hleluzcrkjn	سامسونگ	2026-07-14 13:01:53.484	2026-07-14 13:01:53.484
cmrknuk0e00144hlema8gy8pv	ناتینگ فون	2026-07-14 13:01:53.486	2026-07-14 13:01:53.486
cmrknuk0h00154hlealpjijvx	توشیبا	2026-07-14 13:01:53.489	2026-07-14 13:01:53.489
cmrknuk0l00164hle3cdkoqmz	victus	2026-07-14 13:01:53.493	2026-07-14 13:01:53.493
cmrknuk0p00174hleoejfscfb	ال جی	2026-07-14 13:01:53.498	2026-07-14 13:01:53.498
cmrknuk0s00184hlelqgqvib3	باسئوس	2026-07-14 13:01:53.501	2026-07-14 13:01:53.501
cmrknuk0x00194hlevg4ydqsz	گوگل	2026-07-14 13:01:53.505	2026-07-14 13:01:53.505
cmrknuk10001a4hleuaz2hxwo	هایلو	2026-07-14 13:01:53.508	2026-07-14 13:01:53.508
cmrknuk14001b4hlez02o942h	ZTE	2026-07-14 13:01:53.513	2026-07-14 13:01:53.513
cmrknuk17001c4hlemkzvs9py	اچ پی	2026-07-14 13:01:53.515	2026-07-14 13:01:53.515
cmrknuk1a001d4hles4vy8kk2	وان پلاس	2026-07-14 13:01:53.518	2026-07-14 13:01:53.518
cmrknuk1c001e4hleq9bl3u7w	اوپو	2026-07-14 13:01:53.521	2026-07-14 13:01:53.521
cmrknuk1f001f4hle4qdiojps	ورتو	2026-07-14 13:01:53.524	2026-07-14 13:01:53.524
cmrknuk1k001g4hlenhg99g16	امازفیت	2026-07-14 13:01:53.529	2026-07-14 13:01:53.529
cmrknuk1o001h4hlenpiztgzk	ای مک	2026-07-14 13:01:53.533	2026-07-14 13:01:53.533
cmrknuk1s001i4hleqifj4gnr	نوکیا	2026-07-14 13:01:53.536	2026-07-14 13:01:53.536
cmrknuk1x001j4hle9lgqkq4v	سنی پی اس 4	2026-07-14 13:01:53.541	2026-07-14 13:01:53.541
cmrknuk22001k4hlewvssmg0i	آل این ویر	2026-07-14 13:01:53.547	2026-07-14 13:01:53.547
cmrknuk26001l4hle1mih6mmf	ریلمی	2026-07-14 13:01:53.55	2026-07-14 13:01:53.55
cmrknuk29001m4hle7f34tg5a	لنوو	2026-07-14 13:01:53.553	2026-07-14 13:01:53.553
cmrknuk2c001n4hlebdzlzltg	گارمین	2026-07-14 13:01:53.556	2026-07-14 13:01:53.556
cmrknuk2f001o4hlemtynxx0d	فیت ویت	2026-07-14 13:01:53.56	2026-07-14 13:01:53.56
cmrknuk2j001p4hle30dknop3	انر	2026-07-14 13:01:53.563	2026-07-14 13:01:53.563
cmrknuk2m001q4hlekwqta1w0	تکنو	2026-07-14 13:01:53.567	2026-07-14 13:01:53.567
cmrknuk2p001r4hle44rgi0fl	XIAOMI	2026-07-14 13:01:53.569	2026-07-14 13:01:53.569
\.


--
-- Data for Name: customers; Type: TABLE DATA; Schema: public; Owner: bartar_user
--

COPY public.customers (id, name, phone, "secondaryPhone", address, "createdAt", "updatedAt", "deletedAt") FROM stdin;
cmrkbazbs0000mneo22n4wdvz	رضا	09122255445	\N	\N	2026-07-14 07:10:44.824	2026-07-14 07:10:44.824	\N
\.


--
-- Data for Name: device_models; Type: TABLE DATA; Schema: public; Owner: bartar_user
--

COPY public.device_models (id, name, "brandId", "createdAt", "updatedAt", "deviceTypeId") FROM stdin;
cmrkbazc30003mneojccqn9zn	Galaxy A52	cmrkbazbx0001mneo2r1y2f90	2026-07-14 07:10:44.835	2026-07-14 07:10:44.835	\N
cmrkbxs700015v0qqtfqefy5a	a16	cmrkbazbx0001mneo2r1y2f90	2026-07-14 07:28:28.669	2026-07-14 07:28:28.669	cmrkb3cy40000y9h6lftwhcie
cmrknuk32001t4hlelu9sib7y	xiaomi 11t	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:53.582	2026-07-14 13:01:53.582	cmrkb3cy40000y9h6lftwhcie
cmrknuk38001v4hlegjx5r1co	Moto G52	cmrknujz5000r4hleshjq47jw	2026-07-14 13:01:53.588	2026-07-14 13:01:53.588	cmrkb3cy40000y9h6lftwhcie
cmrknuk3d001x4hle2yo8ceck	HONOR View 20	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:53.593	2026-07-14 13:01:53.593	cmrkb3cy40000y9h6lftwhcie
cmrknuk3i001z4hlepd83wd9l	G814J	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:53.598	2026-07-14 13:01:53.598	cmrknujxm000b4hle4o2fwrvs
cmrknuk3m00214hleqygbqv6j	Galaxy S21 5G	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:53.602	2026-07-14 13:01:53.602	cmrkb3cy40000y9h6lftwhcie
cmrknuk3p00234hleidof9g9j	G73G	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:53.606	2026-07-14 13:01:53.606	cmrknujxm000b4hle4o2fwrvs
cmrknuk3u00254hlenurv8xod	Poco X3 Pro	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:53.61	2026-07-14 13:01:53.61	cmrkb3cy40000y9h6lftwhcie
cmrknuk3y00274hlee5av47jg	Huawei Y6 3g	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:53.614	2026-07-14 13:01:53.614	cmrkb3cy40000y9h6lftwhcie
cmrknuk4100294hleyaen0tey	Galaxy Tab A7	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:53.618	2026-07-14 13:01:53.618	cmrkb3cyo0001y9h6bozaifdg
cmrknuk45002b4hle2tooy7xy	8 PLUSE	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:53.621	2026-07-14 13:01:53.621	cmrkb3cy40000y9h6lftwhcie
cmrknuk4a002d4hlew830h073	ROG Cetra True	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:53.626	2026-07-14 13:01:53.626	cmrknujwg00004hlezsabsciv
cmrknuk4f002f4hleifvlba0s	ROG Cetra True (ایرپاد)	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:53.631	2026-07-14 13:01:53.631	cmrknujxx000f4hle4jp78rc5
cmrknuk4m002h4hle3esydnsl	rog	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:53.639	2026-07-14 13:01:53.639	cmrknujxx000f4hle4jp78rc5
cmrknuk4s002j4hleaik61fcu	7 PLUS	cmrknuk1s001i4hleqifj4gnr	2026-07-14 13:01:53.644	2026-07-14 13:01:53.644	cmrkb3cy40000y9h6lftwhcie
cmrknuk4w002l4hlepsz89rxi	POCO F3 5G	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:53.648	2026-07-14 13:01:53.648	cmrkb3cy40000y9h6lftwhcie
cmrknuk50002n4hlevq2b3czx	Galaxy A13	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:53.652	2026-07-14 13:01:53.652	cmrkb3cy40000y9h6lftwhcie
cmrknuk53002p4hlerbrbz5nn	A2681	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:53.655	2026-07-14 13:01:53.655	cmrknujxm000b4hle4o2fwrvs
cmrknuk57002r4hlelw0zsrh3	Xiaomi 14TI	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:53.66	2026-07-14 13:01:53.66	cmrkb3cy40000y9h6lftwhcie
cmrknuk5b002t4hlexitzn7zc	V241E	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:53.664	2026-07-14 13:01:53.664	cmrknujxu000e4hle1dgnvong
cmrknuk5f002v4hleo5k1c2ex	Nexus	cmrknujz5000r4hleshjq47jw	2026-07-14 13:01:53.667	2026-07-14 13:01:53.667	cmrkb3cy40000y9h6lftwhcie
cmrknuk5i002x4hle5tf2ss26	NOVA 5T	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:53.67	2026-07-14 13:01:53.67	cmrkb3cy40000y9h6lftwhcie
cmrknuk5l002z4hlem8amfrpc	FLMH-X	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:53.673	2026-07-14 13:01:53.673	cmrknujxm000b4hle4o2fwrvs
cmrknuk5p00314hle5gapfra7	S1	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:53.678	2026-07-14 13:01:53.678	cmrknujwz00044hle5lxikvcu
cmrknuk5t00334hle3s1suk8r	VX5-591G	cmrknuk0500114hleha2g5pf3	2026-07-14 13:01:53.681	2026-07-14 13:01:53.681	cmrknujxm000b4hle4o2fwrvs
cmrknuk5w00354hle86yofmw5	FL8000U	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:53.685	2026-07-14 13:01:53.685	cmrknujxm000b4hle4o2fwrvs
cmrknuk6000374hlet0dwerdm	IDEAPAD L3 15IML05	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:01:53.688	2026-07-14 13:01:53.688	cmrkb3cyo0001y9h6bozaifdg
cmrknuk6400394hleffg72tq9	SOUNDPEATS1	cmrknujyz000p4hley4g9fw4c	2026-07-14 13:01:53.692	2026-07-14 13:01:53.692	cmrknujxx000f4hle4jp78rc5
cmrknuk68003b4hleloxciixq	Galaxy A7 2017	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:53.696	2026-07-14 13:01:53.696	cmrkb3cy40000y9h6lftwhcie
cmrknuk6c003d4hle2ymkgicg	edge 20poro	cmrknujz5000r4hleshjq47jw	2026-07-14 13:01:53.7	2026-07-14 13:01:53.7	cmrkb3cy40000y9h6lftwhcie
cmrknuk6f003f4hlep4syh39j	N560ngw	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:53.704	2026-07-14 13:01:53.704	cmrknujxm000b4hle4o2fwrvs
cmrknuk6j003h4hlexaqiufv7	jdn2l09	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:53.708	2026-07-14 13:01:53.708	cmrkb3cyo0001y9h6bozaifdg
cmrknuk6n003j4hle8mtalbfu	GTS2E	cmrknuk1k001g4hlenhg99g16	2026-07-14 13:01:53.711	2026-07-14 13:01:53.711	cmrknujwz00044hle5lxikvcu
cmrknuk6r003l4hlelhknujmz	VOSTRO-1500	cmrknujzd000t4hle1ujh33no	2026-07-14 13:01:53.715	2026-07-14 13:01:53.715	cmrknujxm000b4hle4o2fwrvs
cmrknuk6u003n4hlebenukkli	Redmi A3x	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:53.718	2026-07-14 13:01:53.718	cmrkb3cy40000y9h6lftwhcie
cmrknuk6y003p4hlei7hejidr	SM-G920FD	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:53.722	2026-07-14 13:01:53.722	cmrkb3cy40000y9h6lftwhcie
cmrknuk72003r4hletw2zf8me	SM-G955FD	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:53.726	2026-07-14 13:01:53.726	cmrkb3cy40000y9h6lftwhcie
cmrknuk76003t4hleiwmubscb	razar	cmrknujz5000r4hleshjq47jw	2026-07-14 13:01:53.73	2026-07-14 13:01:53.73	cmrkb3cy40000y9h6lftwhcie
cmrknuk7a003v4hleehxik8k1	G531H	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:53.735	2026-07-14 13:01:53.735	cmrkb3cy40000y9h6lftwhcie
cmrknuk7e003x4hleakqib6r2	A14	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:53.739	2026-07-14 13:01:53.739	cmrkb3cy40000y9h6lftwhcie
cmrknuk7i003z4hle0buu3tbt	Galaxy Tab 2	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:53.742	2026-07-14 13:01:53.742	cmrkb3cyo0001y9h6bozaifdg
cmrknuk7m00414hle3y9dbzog	A2634	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:53.746	2026-07-14 13:01:53.746	cmrkb3cy40000y9h6lftwhcie
cmrknuk7p00434hlezdidh9zt	A2111	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:53.75	2026-07-14 13:01:53.75	cmrkb3cy40000y9h6lftwhcie
cmrknuk7t00454hlesswwen9s	A1779	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:53.753	2026-07-14 13:01:53.753	cmrkb3cy40000y9h6lftwhcie
cmrknuk7x00474hlej3p691u1	A2223	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:53.757	2026-07-14 13:01:53.757	cmrkb3cy40000y9h6lftwhcie
cmrknuk8100494hle5mc1kp7v	A2176	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:53.761	2026-07-14 13:01:53.761	cmrkb3cy40000y9h6lftwhcie
cmrknuk85004b4hleiazgw1ah	Poco F4 5g	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:53.765	2026-07-14 13:01:53.765	cmrkb3cy40000y9h6lftwhcie
cmrknuk88004d4hled5g02jit	Xiaomi Redmi 15	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:53.768	2026-07-14 13:01:53.768	cmrkb3cy40000y9h6lftwhcie
cmrknuk8b004f4hle6skl3bny	518129prc	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:53.772	2026-07-14 13:01:53.772	cmrkb3cy40000y9h6lftwhcie
cmrknuk8f004h4hle1z6ve573	12 Pro	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:53.775	2026-07-14 13:01:53.775	cmrkb3cy40000y9h6lftwhcie
cmrknuk8j004j4hlen4mdi83s	a2700	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:53.78	2026-07-14 13:01:53.78	cmrknujxx000f4hle4jp78rc5
cmrknuk8n004l4hletx4nn2ze	sm r960	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:53.783	2026-07-14 13:01:53.783	cmrknujwz00044hle5lxikvcu
cmrknuk8q004n4hlef8hes2bo	sam j610fds	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:53.786	2026-07-14 13:01:53.786	cmrkb3cy40000y9h6lftwhcie
cmrknuk8t004p4hlevqbhm2lw	Redmi Note 10 pro	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:53.789	2026-07-14 13:01:53.789	cmrkb3cy40000y9h6lftwhcie
cmrknuk8x004r4hle918vk2k2	XT-2551-6	cmrknujz5000r4hleshjq47jw	2026-07-14 13:01:53.794	2026-07-14 13:01:53.794	cmrkb3cy40000y9h6lftwhcie
cmrknuk92004t4hle8c8mwm3b	A3108	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:53.798	2026-07-14 13:01:53.798	cmrkb3cy40000y9h6lftwhcie
cmrknuk96004v4hlemgjnlrfb	SM-A426	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:53.802	2026-07-14 13:01:53.802	cmrkb3cy40000y9h6lftwhcie
cmrknuk9b004x4hle4psa2385	CAM-L21	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:53.808	2026-07-14 13:01:53.808	cmrkb3cy40000y9h6lftwhcie
cmrknuk9h004z4hlez1c5qkb2	moto g35 5g	cmrknujz5000r4hleshjq47jw	2026-07-14 13:01:53.814	2026-07-14 13:01:53.814	cmrkb3cy40000y9h6lftwhcie
cmrknuk9m00514hleychr4spm	Note 9S	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:53.819	2026-07-14 13:01:53.819	cmrkb3cy40000y9h6lftwhcie
cmrknuk9s00534hlejv2hufyh	N24Q11	cmrknuk0500114hleha2g5pf3	2026-07-14 13:01:53.824	2026-07-14 13:01:53.824	cmrknujxm000b4hle4o2fwrvs
cmrknuk9x00554hle9um1cc7q	s23ultra	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:53.83	2026-07-14 13:01:53.83	cmrkb3cy40000y9h6lftwhcie
cmrknuka300574hle2lo3qfyw	PO Box 12987	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:53.835	2026-07-14 13:01:53.835	cmrkb3cy40000y9h6lftwhcie
cmrknuka800594hleq08jlvu9	NIC-LX2	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:53.84	2026-07-14 13:01:53.84	cmrkb3cy40000y9h6lftwhcie
cmrknukad005b4hle2w8tz2im	Mate 8	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:53.846	2026-07-14 13:01:53.846	cmrkb3cy40000y9h6lftwhcie
cmrknukaj005d4hledoif8602	Nova 2 Plus	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:53.851	2026-07-14 13:01:53.851	cmrkb3cy40000y9h6lftwhcie
cmrknukao005f4hle9fi9lqkd	S20 FE	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:53.856	2026-07-14 13:01:53.856	cmrkb3cy40000y9h6lftwhcie
cmrknukau005h4hledgwov1kv	A2644	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:53.862	2026-07-14 13:01:53.862	cmrkb3cy40000y9h6lftwhcie
cmrknukb2005j4hlebfn8v27o	2201116sg	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:53.87	2026-07-14 13:01:53.87	cmrkb3cy40000y9h6lftwhcie
cmrknukb7005l4hleev2lhjty	M2012K11AG	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:53.876	2026-07-14 13:01:53.876	cmrkb3cy40000y9h6lftwhcie
cmrknukbd005n4hlegnj3y3ms	XT22031	cmrknujz5000r4hleshjq47jw	2026-07-14 13:01:53.881	2026-07-14 13:01:53.881	cmrkb3cy40000y9h6lftwhcie
cmrknukbh005p4hleg1hh69cf	Xt2073-1	cmrknujz5000r4hleshjq47jw	2026-07-14 13:01:53.886	2026-07-14 13:01:53.886	cmrkb3cy40000y9h6lftwhcie
cmrknukbm005r4hlecb4jftkf	A2733 SEGEN2	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:53.891	2026-07-14 13:01:53.891	cmrknujwz00044hle5lxikvcu
cmrknukbs005t4hlee8fyoobf	RTL8822CE	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:01:53.896	2026-07-14 13:01:53.896	cmrknujx800074hlexsapxr4z
cmrknukbx005v4hlem1kv0f33	G533Z	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:53.902	2026-07-14 13:01:53.902	cmrknujxm000b4hle4o2fwrvs
cmrknukc2005x4hleh5nk81fh	Moto E5 Plus	cmrknujz5000r4hleshjq47jw	2026-07-14 13:01:53.907	2026-07-14 13:01:53.907	cmrkb3cy40000y9h6lftwhcie
cmrknukc9005z4hlelq7l9xfe	oto E5 Plusm	cmrknujz5000r4hleshjq47jw	2026-07-14 13:01:53.913	2026-07-14 13:01:53.913	cmrkb3cy40000y9h6lftwhcie
cmrknukce00614hlem0s2fz7n	KLV-32S310A	cmrknujyl000l4hlezisknz7b	2026-07-14 13:01:53.918	2026-07-14 13:01:53.918	cmrknujy0000g4hleg9xefyth
cmrknukcj00634hlez8h4mhht	J6 Plus	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:53.924	2026-07-14 13:01:53.924	cmrkb3cy40000y9h6lftwhcie
cmrknukcq00654hletx9kk89c	Edge40 NEO	cmrknujz5000r4hleshjq47jw	2026-07-14 13:01:53.93	2026-07-14 13:01:53.93	cmrkb3cy40000y9h6lftwhcie
cmrknukcv00674hlej43clu7l	P30 Lite	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:53.936	2026-07-14 13:01:53.936	cmrkb3cy40000y9h6lftwhcie
cmrknukd000694hle3fdsm83g	A1419	cmrknuk1o001h4hlenpiztgzk	2026-07-14 13:01:53.941	2026-07-14 13:01:53.941	cmrknujx800074hlexsapxr4z
cmrknukd6006b4hleip3yjoep	FNE-NX9	cmrknujyo000m4hlecl948w9e	2026-07-14 13:01:53.947	2026-07-14 13:01:53.947	cmrkb3cy40000y9h6lftwhcie
cmrknukdc006d4hlea2a8hb3b	Xiaomi 12	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:53.952	2026-07-14 13:01:53.952	cmrkb3cy40000y9h6lftwhcie
cmrknukdi006f4hle8e0nmb1b	watch fit2	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:53.959	2026-07-14 13:01:53.959	cmrknujwz00044hle5lxikvcu
cmrknukdp006h4hlew8pgxujy	G14	cmrknujz5000r4hleshjq47jw	2026-07-14 13:01:53.965	2026-07-14 13:01:53.965	cmrkb3cy40000y9h6lftwhcie
cmrknukdv006j4hleesbzafs5	A2639	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:53.971	2026-07-14 13:01:53.971	cmrkb3cy40000y9h6lftwhcie
cmrknuke1006l4hledh7zmr2j	A6420	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:53.977	2026-07-14 13:01:53.977	cmrknujx800074hlexsapxr4z
cmrknuke7006n4hleslyy98ne	pp42l	cmrknujzd000t4hle1ujh33no	2026-07-14 13:01:53.983	2026-07-14 13:01:53.983	cmrknujxm000b4hle4o2fwrvs
cmrknuked006p4hlemgyj27dq	A71	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:53.989	2026-07-14 13:01:53.989	cmrkb3cy40000y9h6lftwhcie
cmrknukej006r4hle2hso1rb8	MI 14T 5G	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:53.995	2026-07-14 13:01:53.995	cmrkb3cy40000y9h6lftwhcie
cmrknukeo006t4hledwi614zy	Galaxy S25 Ultra	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:54.001	2026-07-14 13:01:54.001	cmrkb3cy40000y9h6lftwhcie
cmrknuket006v4hle4a61ktx6	Galaxy S25	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:54.006	2026-07-14 13:01:54.006	cmrkb3cy40000y9h6lftwhcie
cmrknukez006x4hlegaih19xk	SM-S711B/DS	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:54.012	2026-07-14 13:01:54.012	cmrkb3cy40000y9h6lftwhcie
cmrknukf5006z4hleqkmh6fuc	A31	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:54.017	2026-07-14 13:01:54.017	cmrkb3cy40000y9h6lftwhcie
cmrknukf800714hle56yezt5x	XT2087-2	cmrknujz5000r4hleshjq47jw	2026-07-14 13:01:54.021	2026-07-14 13:01:54.021	cmrkb3cy40000y9h6lftwhcie
cmrknukfd00734hle3vrdh3jy	E5-521-26LT	cmrknuk0500114hleha2g5pf3	2026-07-14 13:01:54.025	2026-07-14 13:01:54.025	cmrknujxm000b4hle4o2fwrvs
cmrknukfh00754hle1fqaljae	EDGE-30FUSION	cmrknujz5000r4hleshjq47jw	2026-07-14 13:01:54.029	2026-07-14 13:01:54.029	cmrkb3cy40000y9h6lftwhcie
cmrknukfk00774hleusq2y3be	aspire switch 10	cmrknuk0500114hleha2g5pf3	2026-07-14 13:01:54.032	2026-07-14 13:01:54.032	cmrknujxm000b4hle4o2fwrvs
cmrknukfn00794hlejcha8lmz	SM-928U	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:54.035	2026-07-14 13:01:54.035	cmrkb3cy40000y9h6lftwhcie
cmrknukfq007b4hlen2411lz6	P20 LITE	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:54.038	2026-07-14 13:01:54.038	cmrkb3cy40000y9h6lftwhcie
cmrknukfs007d4hlee4ub0e4e	POCO PAD	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:54.041	2026-07-14 13:01:54.041	cmrkb3cyo0001y9h6bozaifdg
cmrknukfw007f4hlebag9rapv	SM-J701F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:54.044	2026-07-14 13:01:54.044	cmrkb3cy40000y9h6lftwhcie
cmrknukfz007h4hle81hnjcv8	N56U	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:54.047	2026-07-14 13:01:54.047	cmrknujxm000b4hle4o2fwrvs
cmrknukg1007j4hleasb2a0qd	NOKIA 1 PLUS	cmrknuk1s001i4hleqifj4gnr	2026-07-14 13:01:54.05	2026-07-14 13:01:54.05	cmrkb3cy40000y9h6lftwhcie
cmrknukg4007l4hlejnpldf1i	S5420AP	cmrknuk1s001i4hleqifj4gnr	2026-07-14 13:01:54.053	2026-07-14 13:01:54.053	cmrkb3cy40000y9h6lftwhcie
cmrknukg7007n4hle8nw21o5b	A21-S	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:54.055	2026-07-14 13:01:54.055	cmrkb3cy40000y9h6lftwhcie
cmrknukg9007p4hle9wr1hvkh	A3523	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:54.057	2026-07-14 13:01:54.057	cmrkb3cy40000y9h6lftwhcie
cmrknukgc007r4hleikqsbnij	NOTE 20	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:54.06	2026-07-14 13:01:54.06	cmrkb3cy40000y9h6lftwhcie
cmrknukge007t4hle7nzd1gba	SM-A336E	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:54.063	2026-07-14 13:01:54.063	cmrkb3cy40000y9h6lftwhcie
cmrknukgg007v4hleuwekgkg3	xt1941	cmrknujz5000r4hleshjq47jw	2026-07-14 13:01:54.065	2026-07-14 13:01:54.065	cmrkb3cy40000y9h6lftwhcie
cmrknukgi007x4hleudpeccvg	A1898	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:54.067	2026-07-14 13:01:54.067	cmrkb3cy40000y9h6lftwhcie
cmrknukgl007z4hle7kxb6xfc	REDMI NOT9	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:54.069	2026-07-14 13:01:54.069	cmrkb3cy40000y9h6lftwhcie
cmrknukgn00814hlepm6rd8tp	NP300E5X	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:54.072	2026-07-14 13:01:54.072	cmrknujxm000b4hle4o2fwrvs
cmrknukgr00834hleor5it9na	SAMSUNG G5	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:54.075	2026-07-14 13:01:54.075	cmrkb3cy40000y9h6lftwhcie
cmrknukgu00854hled0yc7la9	A540U	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:54.079	2026-07-14 13:01:54.079	cmrknujxm000b4hle4o2fwrvs
cmrknukgy00874hlewq4l7lz6	MI 1	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:54.083	2026-07-14 13:01:54.083	cmrkb3cy40000y9h6lftwhcie
cmrknukh200894hlemhblb0rf	K55U	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:54.086	2026-07-14 13:01:54.086	cmrknujxm000b4hle4o2fwrvs
cmrknukh4008b4hle6hier6zf	LEGION  9 161RX9	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:01:54.089	2026-07-14 13:01:54.089	cmrknujxm000b4hle4o2fwrvs
cmrknukh6008d4hle1b6rd55x	A2116	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:54.091	2026-07-14 13:01:54.091	cmrknujx800074hlexsapxr4z
cmrknukhb008f4hle5zvkb0x6	REDMI NOTE 14 PRO + 5G	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:54.095	2026-07-14 13:01:54.095	cmrkb3cy40000y9h6lftwhcie
cmrknukhd008h4hley8jvqjxh	K6500Z	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:54.098	2026-07-14 13:01:54.098	cmrknujxm000b4hle4o2fwrvs
cmrknukhg008j4hle3cbbnfvr	moto g 5g	cmrknujz5000r4hleshjq47jw	2026-07-14 13:01:54.1	2026-07-14 13:01:54.1	cmrkb3cy40000y9h6lftwhcie
cmrknukhk008l4hlet4uohpsw	MOTO RAZR 40 ULTRA	cmrknujz5000r4hleshjq47jw	2026-07-14 13:01:54.105	2026-07-14 13:01:54.105	cmrkb3cy40000y9h6lftwhcie
cmrknukhn008n4hle7cs73fej	M2323W1	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:54.107	2026-07-14 13:01:54.107	cmrknujwz00044hle5lxikvcu
cmrknukhq008p4hleo6twystd	N20C1	cmrknuk0500114hleha2g5pf3	2026-07-14 13:01:54.11	2026-07-14 13:01:54.11	cmrknujxm000b4hle4o2fwrvs
cmrknukhs008r4hlehirnsf6w	MOTO E7	cmrknujz5000r4hleshjq47jw	2026-07-14 13:01:54.112	2026-07-14 13:01:54.112	cmrkb3cy40000y9h6lftwhcie
cmrknukhu008t4hle7s7log2r	GT3 SE	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:54.114	2026-07-14 13:01:54.114	cmrknujwz00044hle5lxikvcu
cmrknukhv008v4hle3439xug4	K556U	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:54.116	2026-07-14 13:01:54.116	cmrknujxm000b4hle4o2fwrvs
cmrknukhx008x4hlevbxvd2up	X513E	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:54.118	2026-07-14 13:01:54.118	cmrknujxm000b4hle4o2fwrvs
cmrknukhz008z4hle25k2tic9	XT2159-3	cmrknujz5000r4hleshjq47jw	2026-07-14 13:01:54.12	2026-07-14 13:01:54.12	cmrkb3cy40000y9h6lftwhcie
cmrknuki100914hleaxh4lulp	SAMSUNG S24 U	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:54.121	2026-07-14 13:01:54.121	cmrkb3cy40000y9h6lftwhcie
cmrknuki300934hle8ixf92ig	A51	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:54.123	2026-07-14 13:01:54.123	cmrkb3cy40000y9h6lftwhcie
cmrknuki500954hleu3arq828	V3-571G	cmrknuk0500114hleha2g5pf3	2026-07-14 13:01:54.126	2026-07-14 13:01:54.126	cmrknujxm000b4hle4o2fwrvs
cmrknuki800974hle0zypstuc	SAMSUNG S 24 U	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:54.128	2026-07-14 13:01:54.128	cmrkb3cy40000y9h6lftwhcie
cmrknukia00994hlemkfyw99o	B50-70	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:01:54.13	2026-07-14 13:01:54.13	cmrknujxm000b4hle4o2fwrvs
cmrknukib009b4hlew8uf3jz5	Z5WV2	cmrknuk0500114hleha2g5pf3	2026-07-14 13:01:54.132	2026-07-14 13:01:54.132	cmrknujxm000b4hle4o2fwrvs
cmrknukid009d4hlejp5ntjfo	16 pro max	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:54.134	2026-07-14 13:01:54.134	cmrkb3cy40000y9h6lftwhcie
cmrknukif009f4hleo3bidno7	REALME GT 3	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:54.135	2026-07-14 13:01:54.135	cmrkb3cy40000y9h6lftwhcie
cmrknukih009h4hlewa02jz41	MOTO G60 S	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:54.137	2026-07-14 13:01:54.137	cmrkb3cy40000y9h6lftwhcie
cmrknukii009j4hlep2sefig3	MACHC-WFE9Q	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:54.139	2026-07-14 13:01:54.139	cmrknujxm000b4hle4o2fwrvs
cmrknukil009l4hlegow2cvvz	HP ZBOOK STUDIO G3	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:01:54.141	2026-07-14 13:01:54.141	cmrknujxm000b4hle4o2fwrvs
cmrknukio009n4hlem3vh1cd1	PCG-3D3L	cmrknujyl000l4hlezisknz7b	2026-07-14 13:01:54.144	2026-07-14 13:01:54.144	cmrknujxm000b4hle4o2fwrvs
cmrknukiq009p4hleq3r6mrla	MOTO G24	cmrknujz5000r4hleshjq47jw	2026-07-14 13:01:54.146	2026-07-14 13:01:54.146	cmrkb3cy40000y9h6lftwhcie
cmrknukir009r4hlewgnx0n0z	POCO C85	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:54.148	2026-07-14 13:01:54.148	cmrkb3cy40000y9h6lftwhcie
cmrknukiu009t4hlerhv6y22m	s22 ultra	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:54.15	2026-07-14 13:01:54.15	cmrkb3cy40000y9h6lftwhcie
cmrknukix009v4hleriqre0z6	m2004j19ag	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:54.153	2026-07-14 13:01:54.153	cmrkb3cy40000y9h6lftwhcie
cmrknukj1009x4hle6uioxq9r	13 normal	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:54.157	2026-07-14 13:01:54.157	cmrkb3cy40000y9h6lftwhcie
cmrknukj5009z4hlewgd9yzg0	TP3402Z	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:54.161	2026-07-14 13:01:54.161	cmrknujxm000b4hle4o2fwrvs
cmrknukj800a14hle5r15rz48	TP3	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:54.165	2026-07-14 13:01:54.165	cmrknujxm000b4hle4o2fwrvs
cmrknukja00a34hle6snr4wk2	A2636	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:54.167	2026-07-14 13:01:54.167	cmrkb3cy40000y9h6lftwhcie
cmrknukjc00a54hlexdbwq69w	G551V	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:54.169	2026-07-14 13:01:54.169	cmrknujxm000b4hle4o2fwrvs
cmrknukji00a74hleujznz7ux	note 20 u	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:54.174	2026-07-14 13:01:54.174	cmrkb3cy40000y9h6lftwhcie
cmrknukjp00a94hle8p2kdowr	moto edge 50 pro	cmrknujz5000r4hleshjq47jw	2026-07-14 13:01:54.182	2026-07-14 13:01:54.182	cmrkb3cy40000y9h6lftwhcie
cmrknukjw00ab4hle7bv2439y	BOPBM100	cmrknujzy000z4hlef0vui8me	2026-07-14 13:01:54.188	2026-07-14 13:01:54.188	cmrkb3cy40000y9h6lftwhcie
cmrknukk300ad4hleczv47ncs	iphone 14 pro	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:54.195	2026-07-14 13:01:54.195	cmrkb3cy40000y9h6lftwhcie
cmrknukk900af4hlezo8had57	14 promax	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:54.202	2026-07-14 13:01:54.202	cmrkb3cy40000y9h6lftwhcie
cmrknukkg00ah4hlexlqtyiyj	MI NOTE BOOKE PRO	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:54.208	2026-07-14 13:01:54.208	cmrknujxm000b4hle4o2fwrvs
cmrknukko00aj4hle515lwewj	SM_A065F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:54.216	2026-07-14 13:01:54.216	cmrkb3cy40000y9h6lftwhcie
cmrknukku00al4hlewrptn3r2	XT1965	cmrknujz5000r4hleshjq47jw	2026-07-14 13:01:54.222	2026-07-14 13:01:54.222	cmrkb3cy40000y9h6lftwhcie
cmrknukl200an4hlen0i0gosc	ONE A2003	cmrknuk1a001d4hles4vy8kk2	2026-07-14 13:01:54.23	2026-07-14 13:01:54.23	cmrkb3cy40000y9h6lftwhcie
cmrknukl900ap4hlerxx3tf42	ZBOOK FIREFLY 14 G8	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:01:54.237	2026-07-14 13:01:54.237	cmrknujxm000b4hle4o2fwrvs
cmrknuklf00ar4hleefg29am1	ZBOOK FIRRLY 14 GB	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:01:54.244	2026-07-14 13:01:54.244	cmrknujxm000b4hle4o2fwrvs
cmrknuklm00at4hletkkael85	SM-A165F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:54.25	2026-07-14 13:01:54.25	cmrkb3cy40000y9h6lftwhcie
cmrknuklt00av4hlekp03aj4v	A	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:54.257	2026-07-14 13:01:54.257	cmrkb3cy40000y9h6lftwhcie
cmrknukm100ax4hleaa16bvja	BUDS 3	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:54.265	2026-07-14 13:01:54.265	cmrknujws00024hle61bdckim
cmrknukm800az4hleafl361rm	FA1093DX-15	cmrknuk0l00164hle3cdkoqmz	2026-07-14 13:01:54.273	2026-07-14 13:01:54.273	cmrknujxm000b4hle4o2fwrvs
cmrknukmg00b14hlev6dgdz75	SM-S937B	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:54.28	2026-07-14 13:01:54.28	cmrkb3cy40000y9h6lftwhcie
cmrknukmn00b34hle3xo4zo3a	band 8	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:54.287	2026-07-14 13:01:54.287	cmrknujwz00044hle5lxikvcu
cmrknukmu00b54hleocip8l54	UX3405C	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:54.294	2026-07-14 13:01:54.294	cmrknujxm000b4hle4o2fwrvs
cmrknukn100b74hleop34op78	R510D	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:54.302	2026-07-14 13:01:54.302	cmrknujxm000b4hle4o2fwrvs
cmrknukn900b94hlezw14erwu	UA43K5002AK	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:54.309	2026-07-14 13:01:54.309	cmrknujy0000g4hleg9xefyth
cmrknukng00bb4hle8gi940i5	UX431F	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:54.317	2026-07-14 13:01:54.317	cmrknujxm000b4hle4o2fwrvs
cmrknuknp00bd4hle6geu4fl7	UX431F (موبایل)	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:54.325	2026-07-14 13:01:54.325	cmrkb3cy40000y9h6lftwhcie
cmrknuko000bf4hle6s7bejbd	SM-A566B	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:54.337	2026-07-14 13:01:54.337	cmrkb3cy40000y9h6lftwhcie
cmrknuko800bh4hle6oehh3l5	LYO-L21	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:54.344	2026-07-14 13:01:54.344	cmrkb3cy40000y9h6lftwhcie
cmrknukof00bj4hlevbysz2ch	TA-1497	cmrknuk1s001i4hleqifj4gnr	2026-07-14 13:01:54.352	2026-07-14 13:01:54.352	cmrkb3cy40000y9h6lftwhcie
cmrknukoo00bl4hleom3cfir9	MI BAND 9	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:54.36	2026-07-14 13:01:54.36	cmrknujwz00044hle5lxikvcu
cmrknukov00bn4hle1iy3687a	NOTE 14 PRO 4G	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:54.367	2026-07-14 13:01:54.367	cmrkb3cy40000y9h6lftwhcie
cmrknukp400bp4hleuz952hct	BH23QT29A	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:54.376	2026-07-14 13:01:54.376	cmrknujws00024hle61bdckim
cmrknukpc00br4hlefn7zw0s5	ZBOOK FURY16G9	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:01:54.384	2026-07-14 13:01:54.384	cmrknujxm000b4hle4o2fwrvs
cmrknukpj00bt4hlenyr39z18	Mi Max 2	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:54.391	2026-07-14 13:01:54.391	cmrkb3cyo0001y9h6bozaifdg
cmrknukpr00bv4hlemjbo7fuh	15-EC1095AX	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:01:54.399	2026-07-14 13:01:54.399	cmrknujxm000b4hle4o2fwrvs
cmrknukpz00bx4hle6gzz76bz	SM-F741B	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:54.407	2026-07-14 13:01:54.407	cmrkb3cy40000y9h6lftwhcie
cmrknukq700bz4hlece492dy4	sm-f7418	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:54.415	2026-07-14 13:01:54.415	cmrkb3cy40000y9h6lftwhcie
cmrknukqg00c14hlef99vdhll	741	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:54.424	2026-07-14 13:01:54.424	cmrkb3cy40000y9h6lftwhcie
cmrknukqo00c34hlemgdku0nw	PIXLE 8 pro	cmrknuk0x00194hlevg4ydqsz	2026-07-14 13:01:54.433	2026-07-14 13:01:54.433	cmrkb3cy40000y9h6lftwhcie
cmrknukqw00c54hlezby0l3yt	SM-A525F	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:54.44	2026-07-14 13:01:54.44	cmrkb3cy40000y9h6lftwhcie
cmrknukr400c74hlebaqdanx3	fit2	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:54.448	2026-07-14 13:01:54.448	cmrkb3cy40000y9h6lftwhcie
cmrknukrc00c94hlet4p1aamt	REALME 11	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:54.456	2026-07-14 13:01:54.456	cmrkb3cy40000y9h6lftwhcie
cmrknukrj00cb4hleuekx3t07	Xiaomi Redmi 15C	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:54.463	2026-07-14 13:01:54.463	cmrkb3cy40000y9h6lftwhcie
cmrknukrp00cd4hlerscy4n8i	REDMI K50 GAMING	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:54.47	2026-07-14 13:01:54.47	cmrkb3cy40000y9h6lftwhcie
cmrknukrx00cf4hlemdtu1t5o	N20C3	cmrknujzs000x4hlebzvywl20	2026-07-14 13:01:54.477	2026-07-14 13:01:54.477	cmrknujxm000b4hle4o2fwrvs
cmrknuks500ch4hlez3xwmmqk	A2894	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:54.485	2026-07-14 13:01:54.485	cmrkb3cy40000y9h6lftwhcie
cmrknuksc00cj4hlejnjk1jzj	A2+	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:54.492	2026-07-14 13:01:54.492	cmrkb3cy40000y9h6lftwhcie
cmrknuksk00cl4hletrltjl7x	REALME GT NEO 5 SE	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:54.5	2026-07-14 13:01:54.5	cmrkb3cy40000y9h6lftwhcie
cmrknukss00cn4hlerq4zbgm6	K751L	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:54.508	2026-07-14 13:01:54.508	cmrknujxm000b4hle4o2fwrvs
cmrknukt000cp4hleuzye0x0i	SM-G930FD	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:54.516	2026-07-14 13:01:54.516	cmrkb3cy40000y9h6lftwhcie
cmrknukt700cr4hle3ufcgbe2	GT3	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:54.523	2026-07-14 13:01:54.523	cmrknujwz00044hle5lxikvcu
cmrknuktg00ct4hlew4n0ru1h	PIXLE 4A	cmrknuk0x00194hlevg4ydqsz	2026-07-14 13:01:54.532	2026-07-14 13:01:54.532	cmrkb3cy40000y9h6lftwhcie
cmrknukto00cv4hlefbzpo4ef	Xiaomi Redmi 15C 4G	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:54.54	2026-07-14 13:01:54.54	cmrkb3cy40000y9h6lftwhcie
cmrknuktw00cx4hlegqrfnbx6	FRA-B19	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:54.549	2026-07-14 13:01:54.549	cmrkb3cy40000y9h6lftwhcie
cmrknuku400cz4hleemy9nill	XT2133-2	cmrknujz5000r4hleshjq47jw	2026-07-14 13:01:54.556	2026-07-14 13:01:54.556	cmrkb3cy40000y9h6lftwhcie
cmrknukuc00d14hlevdixt3le	FIT 3	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:54.565	2026-07-14 13:01:54.565	cmrknujwz00044hle5lxikvcu
cmrknukuj00d34hleke6opuzt	SM-A356E	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:54.571	2026-07-14 13:01:54.571	cmrkb3cy40000y9h6lftwhcie
cmrknukut00d54hle4prhkdns	TWSEJ10WM	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:54.582	2026-07-14 13:01:54.582	cmrknujws00024hle61bdckim
cmrknukv100d74hlexoep3tt2	SM-R510	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:54.589	2026-07-14 13:01:54.589	cmrknujws00024hle61bdckim
cmrknukv900d94hleipvjr967	ProBook 4530S	cmrknujzy000z4hlef0vui8me	2026-07-14 13:01:54.597	2026-07-14 13:01:54.597	cmrkb3cy40000y9h6lftwhcie
cmrknukvg00db4hlegeijq54a	QCY_T13ANC1	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:54.604	2026-07-14 13:01:54.604	cmrknujxx000f4hle4jp78rc5
cmrknukvn00dd4hle1jx603ra	UX301L	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:54.612	2026-07-14 13:01:54.612	cmrknujxm000b4hle4o2fwrvs
cmrknukvu00df4hlen9qgtgw9	PROBOOK 600 G2 SFF	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:01:54.619	2026-07-14 13:01:54.619	cmrknujxg00094hleveoq8smb
cmrknukw200dh4hle95rwqpr3	A1396	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:54.626	2026-07-14 13:01:54.626	cmrkb3cyo0001y9h6bozaifdg
cmrknukw900dj4hlet83k4osn	W02	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:54.634	2026-07-14 13:01:54.634	cmrknujwz00044hle5lxikvcu
cmrknukwh00dl4hlec8awd070	SM-F956B	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:54.641	2026-07-14 13:01:54.641	cmrkb3cy40000y9h6lftwhcie
cmrknukwp00dn4hleuqg8ctnm	FA507R	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:54.649	2026-07-14 13:01:54.649	cmrknujxm000b4hle4o2fwrvs
cmrknukww00dp4hleczb0lo0k	23073RPBFG	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:54.656	2026-07-14 13:01:54.656	cmrkb3cyo0001y9h6bozaifdg
cmrknukx300dr4hleoltw0md3	BOB-WAI9	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:54.664	2026-07-14 13:01:54.664	cmrknujxm000b4hle4o2fwrvs
cmrknukxa00dt4hle2yhn7la9	V2 LITE	cmrknujyw000o4hlee6zipn1g	2026-07-14 13:01:54.67	2026-07-14 13:01:54.67	cmrkb3cy40000y9h6lftwhcie
cmrknukxi00dv4hleybegnbgv	SM-A605G	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:54.678	2026-07-14 13:01:54.678	cmrkb3cy40000y9h6lftwhcie
cmrknukxq00dx4hlejr91tq0w	SM-R760	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:54.686	2026-07-14 13:01:54.686	cmrknujwz00044hle5lxikvcu
cmrknukxw00dz4hlefdvxkxgy	REALME C61	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:54.692	2026-07-14 13:01:54.692	cmrkb3cy40000y9h6lftwhcie
cmrknuky400e14hleeuzevs48	MS-15-A12U	cmrknujz9000s4hleu8mshqu7	2026-07-14 13:01:54.7	2026-07-14 13:01:54.7	cmrknujxm000b4hle4o2fwrvs
cmrknukyb00e34hlelbxoibug	MACHC-WAE9LP	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:54.707	2026-07-14 13:01:54.707	cmrknujxm000b4hle4o2fwrvs
cmrknukyi00e54hlebu4u0cjd	X9	cmrknujzl000v4hle1n0o4b2k	2026-07-14 13:01:54.715	2026-07-14 13:01:54.715	cmrkb3cy40000y9h6lftwhcie
cmrknukyp00e74hlesyj6rm0a	META VIEW	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:54.722	2026-07-14 13:01:54.722	cmrknujxu000e4hle1dgnvong
cmrknukyx00e94hlex5wzjsm4	SM-A307GN	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:54.729	2026-07-14 13:01:54.729	cmrkb3cy40000y9h6lftwhcie
cmrknukz300eb4hleq5peo81d	LATITUDE5285	cmrknujzd000t4hle1ujh33no	2026-07-14 13:01:54.736	2026-07-14 13:01:54.736	cmrknujxm000b4hle4o2fwrvs
cmrknukzb00ed4hlempg2xnms	SM-R870	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:54.743	2026-07-14 13:01:54.743	cmrknujwz00044hle5lxikvcu
cmrknukzi00ef4hlelw0olf3c	IDEAPAD 3 15IAU7	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:01:54.751	2026-07-14 13:01:54.751	cmrknujxm000b4hle4o2fwrvs
cmrknukzq00eh4hle31iwkta6	INSPIRON 7791	cmrknujzd000t4hle1ujh33no	2026-07-14 13:01:54.758	2026-07-14 13:01:54.758	cmrknujxm000b4hle4o2fwrvs
cmrknukzx00ej4hled8xdqa5j	XT2333-1	cmrknujz5000r4hleshjq47jw	2026-07-14 13:01:54.765	2026-07-14 13:01:54.765	cmrkb3cy40000y9h6lftwhcie
cmrknul0400el4hleto7dpo3s	TA-1206	cmrknuk1s001i4hleqifj4gnr	2026-07-14 13:01:54.772	2026-07-14 13:01:54.772	cmrkb3cy40000y9h6lftwhcie
cmrknul0c00en4hlemx3i65x7	CPH1725	cmrknuk1c001e4hleq9bl3u7w	2026-07-14 13:01:54.78	2026-07-14 13:01:54.78	cmrkb3cy40000y9h6lftwhcie
cmrknul0j00ep4hlef41undvz	RS4 PLUS	cmrknuk10001a4hleuaz2hxwo	2026-07-14 13:01:54.787	2026-07-14 13:01:54.787	cmrknujwz00044hle5lxikvcu
cmrknul0q00er4hlekk7uo40m	L511	cmrknuk10001a4hleuaz2hxwo	2026-07-14 13:01:54.794	2026-07-14 13:01:54.794	cmrknujwz00044hle5lxikvcu
cmrknul0x00et4hlei3xs75ar	TA-1188	cmrknuk1s001i4hleqifj4gnr	2026-07-14 13:01:54.801	2026-07-14 13:01:54.801	cmrkb3cy40000y9h6lftwhcie
cmrknul1400ev4hlesrlw6tqe	SM-X216B	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:54.808	2026-07-14 13:01:54.808	cmrkb3cy40000y9h6lftwhcie
cmrknul1b00ex4hle3pdo1ldh	REDMI 13X	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:54.816	2026-07-14 13:01:54.816	cmrkb3cy40000y9h6lftwhcie
cmrknul1i00ez4hle577s6xxq	REALME 11 PRO PLUS	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:54.822	2026-07-14 13:01:54.822	cmrkb3cy40000y9h6lftwhcie
cmrknul1q00f14hlea11nygmd	MS-1454	cmrknujz9000s4hleu8mshqu7	2026-07-14 13:01:54.83	2026-07-14 13:01:54.83	cmrknujxm000b4hle4o2fwrvs
cmrknul1x00f34hle0z06dmm6	MI PLAY	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:54.838	2026-07-14 13:01:54.838	cmrkb3cy40000y9h6lftwhcie
cmrknul2500f54hleol2u2qo5	15-P210NE	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:01:54.845	2026-07-14 13:01:54.845	cmrknujxm000b4hle4o2fwrvs
cmrknul2c00f74hlegjenoo2c	SERIES 9	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:54.853	2026-07-14 13:01:54.853	cmrknujwz00044hle5lxikvcu
cmrknul2k00f94hle8edpqejf	REDMI NOTE 11S 5G	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:54.86	2026-07-14 13:01:54.86	cmrkb3cy40000y9h6lftwhcie
cmrknul2s00fb4hlev7inxmva	SM-R840	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:54.868	2026-07-14 13:01:54.868	cmrknujwz00044hle5lxikvcu
cmrknul2y00fd4hleoz8wk29k	PIXLE 4XL	cmrknuk0x00194hlevg4ydqsz	2026-07-14 13:01:54.875	2026-07-14 13:01:54.875	cmrkb3cy40000y9h6lftwhcie
cmrknul3600ff4hleycrs7s9p	XT2237-2	cmrknujz5000r4hleshjq47jw	2026-07-14 13:01:54.882	2026-07-14 13:01:54.882	cmrkb3cy40000y9h6lftwhcie
cmrknul3c00fh4hle6j5clmjz	XT2421-2	cmrknujz5000r4hleshjq47jw	2026-07-14 13:01:54.888	2026-07-14 13:01:54.888	cmrkb3cy40000y9h6lftwhcie
cmrknul3k00fj4hlenz6o9u5u	GTR 3 PRO	cmrknuk1k001g4hlenhg99g16	2026-07-14 13:01:54.896	2026-07-14 13:01:54.896	cmrknujwz00044hle5lxikvcu
cmrknul3r00fl4hleue14j0wg	SM-T211	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:54.903	2026-07-14 13:01:54.903	cmrkb3cyo0001y9h6bozaifdg
cmrknul3y00fn4hleaklw1ams	A2035	cmrknuk1k001g4hlenhg99g16	2026-07-14 13:01:54.91	2026-07-14 13:01:54.91	cmrknujwz00044hle5lxikvcu
cmrknul4500fp4hlep9iyg3hw	PCG-71713L	cmrknujyl000l4hlezisknz7b	2026-07-14 13:01:54.917	2026-07-14 13:01:54.917	cmrknujxm000b4hle4o2fwrvs
cmrknul4a00fr4hlehwxqwsnc	SAF15NB1GW	cmrknujyl000l4hlezisknz7b	2026-07-14 13:01:54.922	2026-07-14 13:01:54.922	cmrknujxm000b4hle4o2fwrvs
cmrknul4g00ft4hle9omc81go	TA-1075	cmrknuk1s001i4hleqifj4gnr	2026-07-14 13:01:54.928	2026-07-14 13:01:54.928	cmrkb3cy40000y9h6lftwhcie
cmrknul4l00fv4hleq2gzq8vs	CVF143A1YL	cmrknujyl000l4hlezisknz7b	2026-07-14 13:01:54.933	2026-07-14 13:01:54.933	cmrknujxm000b4hle4o2fwrvs
cmrknul4o00fx4hle6mmgv8y3	13ad002ne	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:01:54.937	2026-07-14 13:01:54.937	cmrknujxm000b4hle4o2fwrvs
cmrknul4s00fz4hlesjsm68kd	15bs027ne	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:01:54.94	2026-07-14 13:01:54.94	cmrknujxm000b4hle4o2fwrvs
cmrknul4w00g14hle7t2nd48v	MT7921	cmrknuk0l00164hle3cdkoqmz	2026-07-14 13:01:54.945	2026-07-14 13:01:54.945	cmrknujxm000b4hle4o2fwrvs
cmrknul5000g34hleh4nxh1z2	SVF152A1WW	cmrknujyl000l4hlezisknz7b	2026-07-14 13:01:54.948	2026-07-14 13:01:54.948	cmrknujxm000b4hle4o2fwrvs
cmrknul5300g54hlevxapj3j3	ZS676KS	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:54.952	2026-07-14 13:01:54.952	cmrkb3cy40000y9h6lftwhcie
cmrknul5600g74hle8hbn7ocg	N53S	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:54.955	2026-07-14 13:01:54.955	cmrknujxm000b4hle4o2fwrvs
cmrknul5900g94hleeafhhuvp	R546J	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:54.958	2026-07-14 13:01:54.958	cmrknujxm000b4hle4o2fwrvs
cmrknul5e00gb4hle17srjcg9	A1619	cmrknuk1k001g4hlenhg99g16	2026-07-14 13:01:54.962	2026-07-14 13:01:54.962	cmrknujwz00044hle5lxikvcu
cmrknul5h00gd4hlezr116efw	A2179	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:54.965	2026-07-14 13:01:54.965	cmrknujxm000b4hle4o2fwrvs
cmrknul5j00gf4hlelg5g46k2	XT2331-3	cmrknujz5000r4hleshjq47jw	2026-07-14 13:01:54.967	2026-07-14 13:01:54.967	cmrkb3cy40000y9h6lftwhcie
cmrknul5l00gh4hlejikqt2ek	RS4 max	cmrknuk10001a4hleuaz2hxwo	2026-07-14 13:01:54.969	2026-07-14 13:01:54.969	cmrknujwz00044hle5lxikvcu
cmrknul5n00gj4hlejyeii0fx	P125	cmrknujzd000t4hle1ujh33no	2026-07-14 13:01:54.971	2026-07-14 13:01:54.971	cmrknujxm000b4hle4o2fwrvs
cmrknul5q00gl4hle3gl1cj9r	A07	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:54.974	2026-07-14 13:01:54.974	cmrkb3cy40000y9h6lftwhcie
cmrknul5t00gn4hle14k2nuub	MIBRO GS PRO	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:54.978	2026-07-14 13:01:54.978	cmrknujwz00044hle5lxikvcu
cmrknul5w00gp4hle8kmvhakg	SM-A415F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:54.98	2026-07-14 13:01:54.98	cmrkb3cy40000y9h6lftwhcie
cmrknul5y00gr4hle2osjz0od	K350K	cmrknuk0p00174hleoejfscfb	2026-07-14 13:01:54.983	2026-07-14 13:01:54.983	cmrkb3cy40000y9h6lftwhcie
cmrknul6000gt4hler69yhzmf	LG-K350K	cmrknuk0p00174hleoejfscfb	2026-07-14 13:01:54.985	2026-07-14 13:01:54.985	cmrkb3cy40000y9h6lftwhcie
cmrknul6300gv4hle5ebdyhz2	MS-AE31	cmrknujz9000s4hleu8mshqu7	2026-07-14 13:01:54.987	2026-07-14 13:01:54.987	cmrknujx800074hlexsapxr4z
cmrknul6500gx4hlepfkz3qiv	C650	cmrknuk0h00154hlealpjijvx	2026-07-14 13:01:54.989	2026-07-14 13:01:54.989	cmrknujxm000b4hle4o2fwrvs
cmrknul6900gz4hleubekqadx	SVF152A29L	cmrknujyl000l4hlezisknz7b	2026-07-14 13:01:54.993	2026-07-14 13:01:54.993	cmrknujxm000b4hle4o2fwrvs
cmrknul6c00h14hleeh8ukjgn	MI 11 LITE 5G	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:54.996	2026-07-14 13:01:54.996	cmrkb3cy40000y9h6lftwhcie
cmrknul6e00h34hlelvkag4a7	tf303cl	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:54.999	2026-07-14 13:01:54.999	cmrkb3cyo0001y9h6bozaifdg
cmrknul6h00h54hlek9hbo09z	SUH-ZCT2E	cmrknuk1x001j4hle9lgqkq4v	2026-07-14 13:01:55.001	2026-07-14 13:01:55.001	cmrknujxj000a4hledariu2zy
cmrknul6j00h74hlesw2fiuxs	CUH-ZCT1E	cmrknuk1x001j4hle9lgqkq4v	2026-07-14 13:01:55.003	2026-07-14 13:01:55.003	cmrknujxj000a4hledariu2zy
cmrknul6l00h94hle9dfcs4gi	VIVOTAB SMART ME400CL	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:55.005	2026-07-14 13:01:55.005	cmrknujxm000b4hle4o2fwrvs
cmrknul6o00hb4hle9j2nev93	Xiaomi Pocophone F1	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:55.008	2026-07-14 13:01:55.008	cmrkb3cy40000y9h6lftwhcie
cmrknul6s00hd4hlerv0vtk90	PAYF0010IN	cmrknujz5000r4hleshjq47jw	2026-07-14 13:01:55.012	2026-07-14 13:01:55.012	cmrkb3cy40000y9h6lftwhcie
cmrknul6v00hf4hleez7ywux0	GT-193001	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:55.015	2026-07-14 13:01:55.015	cmrkb3cy40000y9h6lftwhcie
cmrknul6x00hh4hle6zocj6bc	GTR 2E	cmrknuk1k001g4hlenhg99g16	2026-07-14 13:01:55.018	2026-07-14 13:01:55.018	cmrknujwz00044hle5lxikvcu
cmrknul7000hj4hleg2f2n6ct	V502L	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:55.02	2026-07-14 13:01:55.02	cmrknujxm000b4hle4o2fwrvs
cmrknul7200hl4hleaig5hor2	A2318	cmrknuk1k001g4hlenhg99g16	2026-07-14 13:01:55.023	2026-07-14 13:01:55.023	cmrknujwz00044hle5lxikvcu
cmrknulsj00r94hlectqd3lg0	PS5	cmrknujyl000l4hlezisknz7b	2026-07-14 13:01:55.795	2026-07-14 13:01:55.795	cmrknujwq00014hlesyp4q2hj
cmrknul7700hn4hlexbi1r7x3	V2405A	cmrknujzl000v4hle1n0o4b2k	2026-07-14 13:01:55.028	2026-07-14 13:01:55.028	cmrkb3cy40000y9h6lftwhcie
cmrknul7b00hp4hlevecx6l0l	F5122	cmrknujyl000l4hlezisknz7b	2026-07-14 13:01:55.032	2026-07-14 13:01:55.032	cmrkb3cy40000y9h6lftwhcie
cmrknul7n00hr4hle5me3zsk0	3165NGW	cmrknujz9000s4hleu8mshqu7	2026-07-14 13:01:55.043	2026-07-14 13:01:55.043	cmrknujx800074hlexsapxr4z
cmrknul7s00ht4hlej0dzt1q5	SM-A510F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:55.048	2026-07-14 13:01:55.048	cmrkb3cy40000y9h6lftwhcie
cmrknul7w00hv4hleqqpb6czx	protectsmart	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:01:55.052	2026-07-14 13:01:55.052	cmrknujxm000b4hle4o2fwrvs
cmrknul8000hx4hlero8t8e9w	LATITUDE 7390	cmrknujzd000t4hle1ujh33no	2026-07-14 13:01:55.056	2026-07-14 13:01:55.056	cmrknujxm000b4hle4o2fwrvs
cmrknul8400hz4hlemq8n3h70	LLD-L31	cmrknujyo000m4hlecl948w9e	2026-07-14 13:01:55.061	2026-07-14 13:01:55.061	cmrkb3cy40000y9h6lftwhcie
cmrknul8800i14hleol59noer	XT2087-1	cmrknujz5000r4hleshjq47jw	2026-07-14 13:01:55.065	2026-07-14 13:01:55.065	cmrkb3cy40000y9h6lftwhcie
cmrknul8c00i34hley56j21qf	MOTO G9 PLUS	cmrknujz5000r4hleshjq47jw	2026-07-14 13:01:55.068	2026-07-14 13:01:55.068	cmrkb3cy40000y9h6lftwhcie
cmrknul8g00i54hletuqhknoe	A1723	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:55.072	2026-07-14 13:01:55.072	cmrkb3cy40000y9h6lftwhcie
cmrknul8k00i74hlegod6x4fv	R465E	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:55.076	2026-07-14 13:01:55.076	cmrknujxm000b4hle4o2fwrvs
cmrknul8o00i94hle5ny0jahm	k011	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:55.08	2026-07-14 13:01:55.08	cmrkb3cyo0001y9h6bozaifdg
cmrknul8s00ib4hle9z5dwlt9	650 G3	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:01:55.084	2026-07-14 13:01:55.084	cmrknujxm000b4hle4o2fwrvs
cmrknul8v00id4hley6xx23xb	Y530-U00	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:55.087	2026-07-14 13:01:55.087	cmrkb3cy40000y9h6lftwhcie
cmrknul8z00if4hle8z63cg83	Galaxy Note20 Ultra	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:55.091	2026-07-14 13:01:55.091	cmrkb3cy40000y9h6lftwhcie
cmrknul9300ih4hledd2509yq	PIXLE 4	cmrknuk0x00194hlevg4ydqsz	2026-07-14 13:01:55.095	2026-07-14 13:01:55.095	cmrkb3cy40000y9h6lftwhcie
cmrknul9700ij4hlel8j5sy4q	IDEAPAD Z500	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:01:55.099	2026-07-14 13:01:55.099	cmrknujxm000b4hle4o2fwrvs
cmrknul9a00il4hlerc151eju	LA40D585K7M	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:55.102	2026-07-14 13:01:55.102	cmrknujy0000g4hleg9xefyth
cmrknul9d00in4hlefeqtt07p	MIBRO A2	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:55.106	2026-07-14 13:01:55.106	cmrknujwz00044hle5lxikvcu
cmrknul9h00ip4hlec1do7vjy	HF006	cmrknuk10001a4hleuaz2hxwo	2026-07-14 13:01:55.109	2026-07-14 13:01:55.109	cmrknujwz00044hle5lxikvcu
cmrknul9l00ir4hle7xnl95s1	E540	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:01:55.113	2026-07-14 13:01:55.113	cmrknujxm000b4hle4o2fwrvs
cmrknul9o00it4hlews8iaebp	SM-X110	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:55.117	2026-07-14 13:01:55.117	cmrkb3cyo0001y9h6bozaifdg
cmrknul9s00iv4hle9dl9hnpq	XPS	cmrknujzd000t4hle1ujh33no	2026-07-14 13:01:55.12	2026-07-14 13:01:55.12	cmrknujxm000b4hle4o2fwrvs
cmrknul9v00ix4hle4fpa1oec	V15	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:01:55.124	2026-07-14 13:01:55.124	cmrknujxm000b4hle4o2fwrvs
cmrknul9z00iz4hle7lg92kle	TA-1357	cmrknuk1s001i4hleqifj4gnr	2026-07-14 13:01:55.128	2026-07-14 13:01:55.128	cmrkb3cy40000y9h6lftwhcie
cmrknula300j14hlethrx64qo	GS2 PRO	cmrknuk2c001n4hlebdzlzltg	2026-07-14 13:01:55.131	2026-07-14 13:01:55.131	cmrknujwz00044hle5lxikvcu
cmrknula600j34hlezjkdxmil	X541N	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:55.135	2026-07-14 13:01:55.135	cmrknujxm000b4hle4o2fwrvs
cmrknulaa00j54hle8d06evb2	ET22301	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:55.138	2026-07-14 13:01:55.138	cmrknujx800074hlexsapxr4z
cmrknulad00j74hleopwsxjfo	POCO X7 PRO	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:55.142	2026-07-14 13:01:55.142	cmrkb3cy40000y9h6lftwhcie
cmrknulah00j94hlenai6pzvj	M509D	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:55.146	2026-07-14 13:01:55.146	cmrknujxm000b4hle4o2fwrvs
cmrknulal00jb4hlel4yjjd4m	POCO C71	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:55.149	2026-07-14 13:01:55.149	cmrkb3cy40000y9h6lftwhcie
cmrknulao00jd4hleftryaqam	REDMI WATCH T1	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:55.152	2026-07-14 13:01:55.152	cmrknujwz00044hle5lxikvcu
cmrknular00jf4hlebjy8ckvn	SM-R770	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:55.155	2026-07-14 13:01:55.155	cmrknujwz00044hle5lxikvcu
cmrknulav00jh4hlewku7teop	A2638	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:55.159	2026-07-14 13:01:55.159	cmrkb3cy40000y9h6lftwhcie
cmrknulaz00jj4hletg1t3xhz	WAX-LX1A	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:55.163	2026-07-14 13:01:55.163	cmrkb3cy40000y9h6lftwhcie
cmrknulb200jl4hlem51kh2ci	L55M5-5ARU	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:55.166	2026-07-14 13:01:55.166	cmrknujy0000g4hleg9xefyth
cmrknulb600jn4hle2iuk5t6m	L55M5-5AR	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:55.17	2026-07-14 13:01:55.17	cmrknujy0000g4hleg9xefyth
cmrknulba00jp4hle9kl20ib6	NP530U3C-A01AE	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:55.174	2026-07-14 13:01:55.174	cmrknujxm000b4hle4o2fwrvs
cmrknulbe00jr4hle0es5fff4	SM-P610N	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:55.178	2026-07-14 13:01:55.178	cmrkb3cyo0001y9h6bozaifdg
cmrknulbi00jt4hlem541pvb5	GTS 3	cmrknuk1k001g4hlenhg99g16	2026-07-14 13:01:55.182	2026-07-14 13:01:55.182	cmrknujwz00044hle5lxikvcu
cmrknulbm00jv4hlep4uvb11s	IPI 145	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:01:55.186	2026-07-14 13:01:55.186	cmrknujxm000b4hle4o2fwrvs
cmrknulbp00jx4hleh5b2qrrr	LOQ 15IRX9	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:01:55.19	2026-07-14 13:01:55.19	cmrknujxm000b4hle4o2fwrvs
cmrknulbt00jz4hle7de1bft9	PIXEL 7A	cmrknuk0x00194hlevg4ydqsz	2026-07-14 13:01:55.193	2026-07-14 13:01:55.193	cmrkb3cy40000y9h6lftwhcie
cmrknulbx00k14hle4oabre9c	HAYLOU RS4	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:55.198	2026-07-14 13:01:55.198	cmrknujwz00044hle5lxikvcu
cmrknulc200k34hlez95rwyl1	L1504F	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:55.202	2026-07-14 13:01:55.202	cmrknujxm000b4hle4o2fwrvs
cmrknulc600k54hle3nphdy6u	GTS 2	cmrknuk1k001g4hlenhg99g16	2026-07-14 13:01:55.206	2026-07-14 13:01:55.206	cmrknujwz00044hle5lxikvcu
cmrknulca00k74hleyk98u0yx	N43S	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:55.21	2026-07-14 13:01:55.21	cmrknujxm000b4hle4o2fwrvs
cmrknulcd00k94hled3utts69	THINKPAD T480S	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:01:55.214	2026-07-14 13:01:55.214	cmrknujxm000b4hle4o2fwrvs
cmrknulch00kb4hlemejwa3eb	SENSE	cmrknuk2f001o4hlemtynxx0d	2026-07-14 13:01:55.217	2026-07-14 13:01:55.217	cmrknujwz00044hle5lxikvcu
cmrknulck00kd4hlekk4hqmke	TA-1156	cmrknuk1s001i4hleqifj4gnr	2026-07-14 13:01:55.22	2026-07-14 13:01:55.22	cmrkb3cy40000y9h6lftwhcie
cmrknulcn00kf4hleso6n5kj3	S510U	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:55.223	2026-07-14 13:01:55.223	cmrknujxm000b4hle4o2fwrvs
cmrknulcr00kh4hle100wg54b	A2190	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:55.227	2026-07-14 13:01:55.227	cmrknujxx000f4hle4jp78rc5
cmrknulcu00kj4hle8wl0t7ez	S3	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:55.231	2026-07-14 13:01:55.231	cmrknujwz00044hle5lxikvcu
cmrknulcx00kl4hleyusnt7mj	A72	cmrknuk1c001e4hleq9bl3u7w	2026-07-14 13:01:55.234	2026-07-14 13:01:55.234	cmrkb3cy40000y9h6lftwhcie
cmrknuld100kn4hlen63r41bl	A3185	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:55.237	2026-07-14 13:01:55.237	cmrknujxm000b4hle4o2fwrvs
cmrknuld500kp4hle6onstv48	SM-X205	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:55.241	2026-07-14 13:01:55.241	cmrkb3cyo0001y9h6bozaifdg
cmrknuld900kr4hlesvgn0jwh	C102	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:55.245	2026-07-14 13:01:55.245	cmrknujxc00084hleb13o6z4a
cmrknuldd00kt4hlehkjyh172	M2	cmrknuk0100104hle0biwkdw8	2026-07-14 13:01:55.25	2026-07-14 13:01:55.25	cmrknujwz00044hle5lxikvcu
cmrknuldi00kv4hlexn1qifq1	A1608	cmrknuk1k001g4hlenhg99g16	2026-07-14 13:01:55.254	2026-07-14 13:01:55.254	cmrknujwz00044hle5lxikvcu
cmrknuldl00kx4hleci404ipk	WATCH KS PRO	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:55.258	2026-07-14 13:01:55.258	cmrknujwz00044hle5lxikvcu
cmrknuldq00kz4hle4rrazgf8	SM-J330F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:55.262	2026-07-14 13:01:55.262	cmrkb3cy40000y9h6lftwhcie
cmrknuldt00l14hlek2cvq98i	TB-X505X	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:01:55.265	2026-07-14 13:01:55.265	cmrkb3cyo0001y9h6bozaifdg
cmrknuldw00l34hleyj7rbub9	SM-J500F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:55.268	2026-07-14 13:01:55.268	cmrkb3cy40000y9h6lftwhcie
cmrknuldy00l54hle6jve0fiu	B101US	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:55.271	2026-07-14 13:01:55.271	cmrknujxc00084hleb13o6z4a
cmrknule300l74hlei8gk21gt	A1703	cmrknujy4000h4hlefueee7c4	2026-07-14 13:01:55.275	2026-07-14 13:01:55.275	cmrknujxm000b4hle4o2fwrvs
cmrknule600l94hle26y5zuj8	NP470R5E	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:55.279	2026-07-14 13:01:55.279	cmrknujxm000b4hle4o2fwrvs
cmrknule900lb4hles4kqn2lh	SM-X700	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:55.282	2026-07-14 13:01:55.282	cmrkb3cyo0001y9h6bozaifdg
cmrknulec00ld4hleknudz2ju	v2	cmrknujyw000o4hlee6zipn1g	2026-07-14 13:01:55.285	2026-07-14 13:01:55.285	cmrkb3cy40000y9h6lftwhcie
cmrknulee00lf4hleo3fovzbk	INSPIRON 7559	cmrknujzd000t4hle1ujh33no	2026-07-14 13:01:55.287	2026-07-14 13:01:55.287	cmrknujxm000b4hle4o2fwrvs
cmrknuleg00lh4hle0034tx9a	LATITUDE 3440	cmrknujzd000t4hle1ujh33no	2026-07-14 13:01:55.289	2026-07-14 13:01:55.289	cmrknujxm000b4hle4o2fwrvs
cmrknulej00lj4hlejmw3s3yr	XT1685	cmrknujz5000r4hleshjq47jw	2026-07-14 13:01:55.292	2026-07-14 13:01:55.292	cmrkb3cy40000y9h6lftwhcie
cmrknulem00ll4hle60s8bf7o	GTR 3	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:55.294	2026-07-14 13:01:55.294	cmrknujwz00044hle5lxikvcu
cmrknulep00ln4hlep45h4fzk	SM-G988	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:55.297	2026-07-14 13:01:55.297	cmrkb3cy40000y9h6lftwhcie
cmrknuler00lp4hlebex4bfiy	SM-G510	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:55.3	2026-07-14 13:01:55.3	cmrkb3cy40000y9h6lftwhcie
cmrknulet00lr4hle1ole26j5	LA46D585K7M	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:55.302	2026-07-14 13:01:55.302	cmrknujy0000g4hleg9xefyth
cmrknulew00lt4hleluttgr6j	TA-1183	cmrknuk1s001i4hleqifj4gnr	2026-07-14 13:01:55.304	2026-07-14 13:01:55.304	cmrkb3cy40000y9h6lftwhcie
cmrknuley00lv4hle2knoredi	ELITEBOOK 8560P	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:01:55.306	2026-07-14 13:01:55.306	cmrknujxm000b4hle4o2fwrvs
cmrknulf200lx4hle2t7q0f9o	A2564	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:55.31	2026-07-14 13:01:55.31	cmrknujxx000f4hle4jp78rc5
cmrknulf400lz4hleclr9wpr0	TravelMate P215-53	cmrknuk0500114hleha2g5pf3	2026-07-14 13:01:55.313	2026-07-14 13:01:55.313	cmrknujxm000b4hle4o2fwrvs
cmrknulf700m14hleefa9zyy5	P215-53	cmrknuk0500114hleha2g5pf3	2026-07-14 13:01:55.316	2026-07-14 13:01:55.316	cmrknujxm000b4hle4o2fwrvs
cmrknulf900m34hlecdbk6exa	AN515-43	cmrknuk0500114hleha2g5pf3	2026-07-14 13:01:55.318	2026-07-14 13:01:55.318	cmrknujxm000b4hle4o2fwrvs
cmrknulfb00m54hle0kh3lz3m	SM-X216B (تبلت)	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:55.32	2026-07-14 13:01:55.32	cmrkb3cyo0001y9h6bozaifdg
cmrknulfe00m74hlevv6fjjsd	MI 34	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:55.323	2026-07-14 13:01:55.323	cmrknujxu000e4hle1dgnvong
cmrknulfi00m94hlex460e0vc	REDMI NOTE 14 PRO 5G	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:55.326	2026-07-14 13:01:55.326	cmrkb3cy40000y9h6lftwhcie
cmrknulfk00mb4hleofzuvfpd	Redmi Buds	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:55.329	2026-07-14 13:01:55.329	cmrknujxx000f4hle4jp78rc5
cmrknulfm00md4hleeqh5fo5o	MI WATCH	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:55.331	2026-07-14 13:01:55.331	cmrknujwz00044hle5lxikvcu
cmrknulfp00mf4hlema0ytww5	A1920	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:55.334	2026-07-14 13:01:55.334	cmrkb3cy40000y9h6lftwhcie
cmrknulfr00mh4hleu5iaqfej	A1418	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:55.336	2026-07-14 13:01:55.336	cmrknujx800074hlexsapxr4z
cmrknulft00mj4hle7th4y993	BAND 6	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:55.337	2026-07-14 13:01:55.337	cmrknujwz00044hle5lxikvcu
cmrknulfv00ml4hlex8qv8lk4	M4 PRO	cmrknuk0100104hle0biwkdw8	2026-07-14 13:01:55.34	2026-07-14 13:01:55.34	cmrknujwz00044hle5lxikvcu
cmrknulfz00mn4hlezuktqp8r	GTS 2E	cmrknuk1k001g4hlenhg99g16	2026-07-14 13:01:55.343	2026-07-14 13:01:55.343	cmrknujwz00044hle5lxikvcu
cmrknulg100mp4hlekypkfbly	ASUS-Z01MD	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:55.346	2026-07-14 13:01:55.346	cmrkb3cy40000y9h6lftwhcie
cmrknulg300mr4hle13yiy0nz	A1311	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:55.348	2026-07-14 13:01:55.348	cmrknujx800074hlexsapxr4z
cmrknulg600mt4hlezrvozvi1	SM-T865	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:55.35	2026-07-14 13:01:55.35	cmrkb3cyo0001y9h6bozaifdg
cmrknulg800mv4hle8g6yzz48	SM-G986B	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:55.352	2026-07-14 13:01:55.352	cmrkb3cy40000y9h6lftwhcie
cmrknulg900mx4hlez6w7pmzi	SMG986B	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:55.354	2026-07-14 13:01:55.354	cmrkb3cy40000y9h6lftwhcie
cmrknulgc00mz4hley98rh4vt	one action	cmrknujz5000r4hleshjq47jw	2026-07-14 13:01:55.356	2026-07-14 13:01:55.356	cmrkb3cy40000y9h6lftwhcie
cmrknulgf00n14hle4og3t0c8	TA-1087	cmrknuk1s001i4hleqifj4gnr	2026-07-14 13:01:55.36	2026-07-14 13:01:55.36	cmrkb3cy40000y9h6lftwhcie
cmrknulgi00n34hle2r2wamq5	ME302	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:55.362	2026-07-14 13:01:55.362	cmrkb3cyo0001y9h6bozaifdg
cmrknulgl00n54hlenhoid7lf	AC2003	cmrknuk1a001d4hles4vy8kk2	2026-07-14 13:01:55.366	2026-07-14 13:01:55.366	cmrkb3cy40000y9h6lftwhcie
cmrknulgo00n74hle679slxdy	IN2013	cmrknuk1a001d4hles4vy8kk2	2026-07-14 13:01:55.368	2026-07-14 13:01:55.368	cmrkb3cy40000y9h6lftwhcie
cmrknulgq00n94hlebjhi2cuc	IMISW12	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:55.37	2026-07-14 13:01:55.37	cmrknujwz00044hle5lxikvcu
cmrknulgs00nb4hlemynwh2iu	GM1913	cmrknuk1a001d4hles4vy8kk2	2026-07-14 13:01:55.372	2026-07-14 13:01:55.372	cmrkb3cy40000y9h6lftwhcie
cmrknulgv00nd4hleyopq7toj	SM-A366B	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:55.375	2026-07-14 13:01:55.375	cmrkb3cy40000y9h6lftwhcie
cmrknulgy00nf4hleyg5u1f49	VG27E	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:55.378	2026-07-14 13:01:55.378	cmrknujxu000e4hle1dgnvong
cmrknulh000nh4hle2itxurxf	GTR 2	cmrknuk1k001g4hlenhg99g16	2026-07-14 13:01:55.38	2026-07-14 13:01:55.38	cmrknujwz00044hle5lxikvcu
cmrknulh300nj4hleuocad4k5	SM-A805F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:55.383	2026-07-14 13:01:55.383	cmrkb3cy40000y9h6lftwhcie
cmrknulh500nl4hle8ow20c2x	TREX 2	cmrknuk1k001g4hlenhg99g16	2026-07-14 13:01:55.385	2026-07-14 13:01:55.385	cmrknujwz00044hle5lxikvcu
cmrknulh700nn4hlejcgitf17	NTN-L22	cmrknujyo000m4hlecl948w9e	2026-07-14 13:01:55.387	2026-07-14 13:01:55.387	cmrkb3cy40000y9h6lftwhcie
cmrknulha00np4hlet4mocum4	A1538	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:55.39	2026-07-14 13:01:55.39	cmrkb3cyo0001y9h6bozaifdg
cmrknulhd00nr4hlep94vlisc	SM-T835	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:55.394	2026-07-14 13:01:55.394	cmrkb3cyo0001y9h6bozaifdg
cmrknulhg00nt4hlehgm9tjli	PG248	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:55.396	2026-07-14 13:01:55.396	cmrknujxu000e4hle1dgnvong
cmrknulhj00nv4hles7e9c3qi	1631	cmrknujy4000h4hlefueee7c4	2026-07-14 13:01:55.399	2026-07-14 13:01:55.399	cmrknujxm000b4hle4o2fwrvs
cmrknulhm00nx4hleutnk5b3w	PIXLE 6	cmrknuk0x00194hlevg4ydqsz	2026-07-14 13:01:55.402	2026-07-14 13:01:55.402	cmrkb3cy40000y9h6lftwhcie
cmrknulho00nz4hlehfafdypy	XT2417	cmrknujz5000r4hleshjq47jw	2026-07-14 13:01:55.404	2026-07-14 13:01:55.404	cmrkb3cy40000y9h6lftwhcie
cmrknulhr00o14hle1h8a6dxf	SM-S908B	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:55.408	2026-07-14 13:01:55.408	cmrkb3cy40000y9h6lftwhcie
cmrknulhv00o34hlej38kzly3	c11	cmrknuk26001l4hle1mih6mmf	2026-07-14 13:01:55.412	2026-07-14 13:01:55.412	cmrkb3cy40000y9h6lftwhcie
cmrknulhy00o54hle319x0ivh	VIVO ACTIVE 3	cmrknuk2c001n4hlebdzlzltg	2026-07-14 13:01:55.415	2026-07-14 13:01:55.415	cmrknujwz00044hle5lxikvcu
cmrknuli200o74hletn674hbn	cma-lx2	cmrknujyo000m4hlecl948w9e	2026-07-14 13:01:55.418	2026-07-14 13:01:55.418	cmrkb3cy40000y9h6lftwhcie
cmrknuli400o94hle3ggsatxq	A667L	cmrknujyf000j4hle46icumbs	2026-07-14 13:01:55.421	2026-07-14 13:01:55.421	cmrkb3cy40000y9h6lftwhcie
cmrknuli800ob4hle1apyxvsm	A2016	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:55.424	2026-07-14 13:01:55.424	cmrknujxx000f4hle4jp78rc5
cmrknulic00od4hleq4ig0p2b	REALME C30S	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:55.428	2026-07-14 13:01:55.428	cmrkb3cy40000y9h6lftwhcie
cmrknulig00of4hlelpcat5i5	AN515-55-70UZ	cmrknuk0500114hleha2g5pf3	2026-07-14 13:01:55.433	2026-07-14 13:01:55.433	cmrknujxm000b4hle4o2fwrvs
cmrknulik00oh4hledpuiybss	IDEAPAD5 15AL7	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:01:55.436	2026-07-14 13:01:55.436	cmrknujxm000b4hle4o2fwrvs
cmrknulin00oj4hle3igtdq18	E1504F	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:55.44	2026-07-14 13:01:55.44	cmrknujxm000b4hle4o2fwrvs
cmrknulit00ol4hledwiimb7k	LOQ 15IRH8	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:01:55.445	2026-07-14 13:01:55.445	cmrknujxm000b4hle4o2fwrvs
cmrknuliy00on4hlehg7ndxp6	TANK T3 ULTRA	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:55.451	2026-07-14 13:01:55.451	cmrknujwz00044hle5lxikvcu
cmrknulj300op4hlebq4f6z6x	VG27	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:55.455	2026-07-14 13:01:55.455	cmrknujxu000e4hle1dgnvong
cmrknulj900or4hle4b17prln	WATCH 8	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:55.461	2026-07-14 13:01:55.461	cmrknujwz00044hle5lxikvcu
cmrknuljf00ot4hledyrnjask	REDMI 14C	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:55.467	2026-07-14 13:01:55.467	cmrkb3cy40000y9h6lftwhcie
cmrknuljm00ov4hley49a0ws7	GS2	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:55.474	2026-07-14 13:01:55.474	cmrknujwz00044hle5lxikvcu
cmrknulju00ox4hle4wjomjqp	SM-N770F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:55.482	2026-07-14 13:01:55.482	cmrkb3cy40000y9h6lftwhcie
cmrknulk000oz4hleglox4c13	BIP 3	cmrknuk1k001g4hlenhg99g16	2026-07-14 13:01:55.488	2026-07-14 13:01:55.488	cmrknujwz00044hle5lxikvcu
cmrknulk800p14hle74t90m4g	TREX	cmrknuk1k001g4hlenhg99g16	2026-07-14 13:01:55.496	2026-07-14 13:01:55.496	cmrknujwz00044hle5lxikvcu
cmrknulkf00p34hle8sf552ex	A3010	cmrknuk1a001d4hles4vy8kk2	2026-07-14 13:01:55.503	2026-07-14 13:01:55.503	cmrkb3cy40000y9h6lftwhcie
cmrknulkn00p54hleud7ysws9	KDL-42W670A	cmrknujyl000l4hlezisknz7b	2026-07-14 13:01:55.511	2026-07-14 13:01:55.511	cmrknujy0000g4hleg9xefyth
cmrknulku00p74hleiud1ly21	TA-1094	cmrknuk1s001i4hleqifj4gnr	2026-07-14 13:01:55.519	2026-07-14 13:01:55.519	cmrkb3cy40000y9h6lftwhcie
cmrknull200p94hlextbcwyao	UX392F	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:55.527	2026-07-14 13:01:55.527	cmrknujxm000b4hle4o2fwrvs
cmrknulla00pb4hlega99sdxh	SM-A045F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:55.534	2026-07-14 13:01:55.534	cmrkb3cy40000y9h6lftwhcie
cmrknulli00pd4hle9wawfnz9	SM-S906E	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:55.542	2026-07-14 13:01:55.542	cmrkb3cy40000y9h6lftwhcie
cmrknullq00pf4hlej34ekmm9	M2462W1	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:55.55	2026-07-14 13:01:55.55	cmrknujwz00044hle5lxikvcu
cmrknully00ph4hleez8epbsw	MI 13	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:55.558	2026-07-14 13:01:55.558	cmrkb3cy40000y9h6lftwhcie
cmrknulm500pj4hle2guetpz5	GT7	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:55.565	2026-07-14 13:01:55.565	cmrknujwz00044hle5lxikvcu
cmrknulmc00pl4hleoc7cwfci	XPERIA XA1	cmrknujyl000l4hlezisknz7b	2026-07-14 13:01:55.572	2026-07-14 13:01:55.572	cmrkb3cy40000y9h6lftwhcie
cmrknulmi00pn4hle7bbp4gp0	GTS 4	cmrknuk1k001g4hlenhg99g16	2026-07-14 13:01:55.579	2026-07-14 13:01:55.579	cmrknujwz00044hle5lxikvcu
cmrknulmp00pp4hlet3hpl7rg	POCO M6 4G	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:55.586	2026-07-14 13:01:55.586	cmrkb3cy40000y9h6lftwhcie
cmrknulmx00pr4hleh6418tgt	A000307	cmrknuk1f001f4hle4qdiojps	2026-07-14 13:01:55.594	2026-07-14 13:01:55.594	cmrkb3cy40000y9h6lftwhcie
cmrknuln500pt4hle66uoapbm	SM-R600	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:55.601	2026-07-14 13:01:55.601	cmrknujwz00044hle5lxikvcu
cmrknulnd00pv4hlembyluoib	A3090	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:55.609	2026-07-14 13:01:55.609	cmrkb3cy40000y9h6lftwhcie
cmrknulnl00px4hleoznpjwnm	NX679J	cmrknuk14001b4hlez02o942h	2026-07-14 13:01:55.617	2026-07-14 13:01:55.617	cmrkb3cy40000y9h6lftwhcie
cmrknulns00pz4hletovgjakd	XT1687	cmrknujz5000r4hleshjq47jw	2026-07-14 13:01:55.624	2026-07-14 13:01:55.624	cmrkb3cy40000y9h6lftwhcie
cmrknulo000q14hlegzdhlk92	SM-S938B	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:55.632	2026-07-14 13:01:55.632	cmrkb3cy40000y9h6lftwhcie
cmrknulo700q34hleoatc219s	NCO-LX1	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:55.639	2026-07-14 13:01:55.639	cmrkb3cy40000y9h6lftwhcie
cmrknuloe00q54hle5daa2x55	SM-A556E	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:55.647	2026-07-14 13:01:55.647	cmrkb3cy40000y9h6lftwhcie
cmrknulom00q74hlex9gudsw6	SM-T330	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:55.654	2026-07-14 13:01:55.654	cmrkb3cyo0001y9h6bozaifdg
cmrknulov00q94hlec0zhwv2i	REDMI WATCH 5	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:55.664	2026-07-14 13:01:55.664	cmrknujwz00044hle5lxikvcu
cmrknulp200qb4hledzuicfqj	SLIM3	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:01:55.67	2026-07-14 13:01:55.67	cmrknujxm000b4hle4o2fwrvs
cmrknulpa00qd4hlexrxploty	SM-R920	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:55.678	2026-07-14 13:01:55.678	cmrknujwz00044hle5lxikvcu
cmrknulpg00qf4hleaptjcucr	UM5302L	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:55.684	2026-07-14 13:01:55.684	cmrknujxm000b4hle4o2fwrvs
cmrknulpo00qh4hleu03oqajh	LITE 3 PRO	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:55.692	2026-07-14 13:01:55.692	cmrknujwz00044hle5lxikvcu
cmrknulpv00qj4hlet9pwdhyd	KW66	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:55.7	2026-07-14 13:01:55.7	cmrknujwz00044hle5lxikvcu
cmrknulq300ql4hleqnitj1ac	REALME NOTE 50	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:55.707	2026-07-14 13:01:55.707	cmrkb3cy40000y9h6lftwhcie
cmrknulqb00qn4hle7xrv151e	RESIST 50M	cmrknuk1k001g4hlenhg99g16	2026-07-14 13:01:55.715	2026-07-14 13:01:55.715	cmrknujwz00044hle5lxikvcu
cmrknulqi00qp4hlej22isqm1	SVE151C11L	cmrknujyl000l4hlezisknz7b	2026-07-14 13:01:55.722	2026-07-14 13:01:55.722	cmrknujxm000b4hle4o2fwrvs
cmrknulqq00qr4hlekpgxxyma	XT2029-2	cmrknujz5000r4hleshjq47jw	2026-07-14 13:01:55.73	2026-07-14 13:01:55.73	cmrkb3cy40000y9h6lftwhcie
cmrknulqx00qt4hle4nrmv8i7	SM-R960	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:55.737	2026-07-14 13:01:55.737	cmrknujwz00044hle5lxikvcu
cmrknulr400qv4hlefohinq51	A2319	cmrknuk1k001g4hlenhg99g16	2026-07-14 13:01:55.745	2026-07-14 13:01:55.745	cmrknujwz00044hle5lxikvcu
cmrknulrb00qx4hlets30l49r	A1549	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:55.752	2026-07-14 13:01:55.752	cmrkb3cy40000y9h6lftwhcie
cmrknulrj00qz4hleoocy374t	A2483	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:55.759	2026-07-14 13:01:55.759	cmrkb3cy40000y9h6lftwhcie
cmrknulrr00r14hlex4h5gage	XT2307-1	cmrknujz5000r4hleshjq47jw	2026-07-14 13:01:55.767	2026-07-14 13:01:55.767	cmrkb3cy40000y9h6lftwhcie
cmrknulry00r34hlei7rdmewo	XT2171-2	cmrknujz5000r4hleshjq47jw	2026-07-14 13:01:55.774	2026-07-14 13:01:55.774	cmrkb3cy40000y9h6lftwhcie
cmrknuls500r54hle69exdk7t	HAYLOU RS4 PLUS	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:55.781	2026-07-14 13:01:55.781	cmrknujwz00044hle5lxikvcu
cmrknulsb00r74hleu6ac20qj	T14 GEN 4	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:01:55.787	2026-07-14 13:01:55.787	cmrknujxm000b4hle4o2fwrvs
cmrknulsr00rb4hleo65hfrkd	SM-A736B	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:55.803	2026-07-14 13:01:55.803	cmrkb3cy40000y9h6lftwhcie
cmrknulsz00rd4hleistc8sfa	GT-P5200	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:55.811	2026-07-14 13:01:55.811	cmrkb3cyo0001y9h6bozaifdg
cmrknult600rf4hlet38y13c8	A2200	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:55.818	2026-07-14 13:01:55.818	cmrkb3cyo0001y9h6bozaifdg
cmrknultd00rh4hlevpw5tiom	N53	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:55.825	2026-07-14 13:01:55.825	cmrknujxm000b4hle4o2fwrvs
cmrknultk00rj4hlehe1ryx7r	SM-A307FN	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:55.832	2026-07-14 13:01:55.832	cmrkb3cy40000y9h6lftwhcie
cmrknultr00rl4hlerrczqyly	S1 ACTIVE	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:55.839	2026-07-14 13:01:55.839	cmrknujwz00044hle5lxikvcu
cmrknulty00rn4hlejjwpmzjt	ODN-B19	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:55.846	2026-07-14 13:01:55.846	cmrknujwz00044hle5lxikvcu
cmrknulu500rp4hlefoq6eqli	SM-R860	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:55.853	2026-07-14 13:01:55.853	cmrknujwz00044hle5lxikvcu
cmrknuluc00rr4hlefa47mt5j	A3000	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:01:55.86	2026-07-14 13:01:55.86	cmrkb3cyo0001y9h6bozaifdg
cmrknuluj00rt4hlej4ze9o14	Z4	cmrknujyl000l4hlezisknz7b	2026-07-14 13:01:55.867	2026-07-14 13:01:55.867	cmrkb3cy40000y9h6lftwhcie
cmrknuluq00rv4hleqwocd9gv	E6553	cmrknujyl000l4hlezisknz7b	2026-07-14 13:01:55.874	2026-07-14 13:01:55.874	cmrkb3cy40000y9h6lftwhcie
cmrknuluy00rx4hle40ufe062	SHT-AL09	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:55.882	2026-07-14 13:01:55.882	cmrkb3cyo0001y9h6bozaifdg
cmrknulv400rz4hle1sy677u6	REALME C51	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:55.889	2026-07-14 13:01:55.889	cmrkb3cy40000y9h6lftwhcie
cmrknulvd00s14hletpuf5os5	1810TZ	cmrknuk0500114hleha2g5pf3	2026-07-14 13:01:55.897	2026-07-14 13:01:55.897	cmrknujxm000b4hle4o2fwrvs
cmrknulvk00s34hleqantyjwy	SM-J530F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:55.904	2026-07-14 13:01:55.904	cmrkb3cy40000y9h6lftwhcie
cmrknulvs00s54hleghm3vyoe	XT2097-13	cmrknujz5000r4hleshjq47jw	2026-07-14 13:01:55.912	2026-07-14 13:01:55.912	cmrkb3cy40000y9h6lftwhcie
cmrknulw000s74hleaid65iwf	MI BAND 2	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:55.92	2026-07-14 13:01:55.92	cmrknujwz00044hle5lxikvcu
cmrknulw800s94hlefioy38yo	NP300E5Z	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:55.929	2026-07-14 13:01:55.929	cmrknujxm000b4hle4o2fwrvs
cmrknulwf00sb4hlees8836jc	ZC600KL	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:55.936	2026-07-14 13:01:55.936	cmrkb3cy40000y9h6lftwhcie
cmrknulwn00sd4hle5q1rpxq7	MS-16GD	cmrknujz9000s4hleu8mshqu7	2026-07-14 13:01:55.943	2026-07-14 13:01:55.943	cmrknujxm000b4hle4o2fwrvs
cmrknulwv00sf4hlefu8pwp6s	HCT-B19	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:55.951	2026-07-14 13:01:55.951	cmrknujwz00044hle5lxikvcu
cmrknulx200sh4hlephqgg7v6	SM-G990B	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:55.959	2026-07-14 13:01:55.959	cmrkb3cy40000y9h6lftwhcie
cmrknulxa00sj4hled425zdiy	X2 PRO 612 G2	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:01:55.966	2026-07-14 13:01:55.966	cmrknujxm000b4hle4o2fwrvs
cmrknulxh00sl4hlenp7opekl	MIBRO LITE 2	cmrknuk1k001g4hlenhg99g16	2026-07-14 13:01:55.973	2026-07-14 13:01:55.973	cmrknujwz00044hle5lxikvcu
cmrknulxo00sn4hlekjxtikuf	L50M6-6ARG	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:55.98	2026-07-14 13:01:55.98	cmrknujy0000g4hleg9xefyth
cmrknulxv00sp4hleva8oikcv	SERIES 6	cmrknuk2f001o4hlemtynxx0d	2026-07-14 13:01:55.987	2026-07-14 13:01:55.987	cmrknujwz00044hle5lxikvcu
cmrknuly300sr4hle95290zpd	MS-AA593	cmrknujz9000s4hleu8mshqu7	2026-07-14 13:01:55.995	2026-07-14 13:01:55.995	cmrknujx800074hlexsapxr4z
cmrknulyb00st4hlehrg2ix3t	MS-AA59	cmrknujz9000s4hleu8mshqu7	2026-07-14 13:01:56.003	2026-07-14 13:01:56.003	cmrknujx800074hlexsapxr4z
cmrknulyj00sv4hle33ptr00a	3165N	cmrknujz9000s4hleu8mshqu7	2026-07-14 13:01:56.011	2026-07-14 13:01:56.011	cmrknujx800074hlexsapxr4z
cmrknulyq00sx4hle1aehwgpb	HSTNN-C87C	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:01:56.018	2026-07-14 13:01:56.018	cmrknujxm000b4hle4o2fwrvs
cmrknulyw00sz4hleb4zin73w	K56 PRO	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:56.025	2026-07-14 13:01:56.025	cmrknujwz00044hle5lxikvcu
cmrknulz300t14hleewkvl9mt	A2897	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:56.032	2026-07-14 13:01:56.032	cmrknujxx000f4hle4jp78rc5
cmrknulza00t34hlehfol6ayi	XT2153-1	cmrknujz5000r4hleshjq47jw	2026-07-14 13:01:56.038	2026-07-14 13:01:56.038	cmrkb3cy40000y9h6lftwhcie
cmrknulzi00t54hletbm3jves	REALME 11 PRO	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:56.046	2026-07-14 13:01:56.046	cmrkb3cy40000y9h6lftwhcie
cmrknulzp00t74hlevl5yumt3	3CC2	cmrknujz9000s4hleu8mshqu7	2026-07-14 13:01:56.053	2026-07-14 13:01:56.053	cmrknujxu000e4hle1dgnvong
cmrknulzv00t94hlenhj72ueo	MAG273	cmrknujz9000s4hleu8mshqu7	2026-07-14 13:01:56.06	2026-07-14 13:01:56.06	cmrknujxu000e4hle1dgnvong
cmrknum0200tb4hlek75rcnm7	SM-T715	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:56.066	2026-07-14 13:01:56.066	cmrkb3cyo0001y9h6bozaifdg
cmrknum0800td4hle6gk4fpe3	MX279	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:56.073	2026-07-14 13:01:56.073	cmrknujxu000e4hle1dgnvong
cmrknum0f00tf4hlemccrf9aj	SVF14N15CD	cmrknujyl000l4hlezisknz7b	2026-07-14 13:01:56.08	2026-07-14 13:01:56.08	cmrknujxm000b4hle4o2fwrvs
cmrknum0m00th4hlebl9gnszj	SVF14N15CB	cmrknujyl000l4hlezisknz7b	2026-07-14 13:01:56.086	2026-07-14 13:01:56.086	cmrknujxm000b4hle4o2fwrvs
cmrknum0t00tj4hlecotpw11q	F0E8	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:01:56.093	2026-07-14 13:01:56.093	cmrknujx800074hlexsapxr4z
cmrknum1200tl4hlemehzkfh1	NE2210	cmrknuk1a001d4hles4vy8kk2	2026-07-14 13:01:56.102	2026-07-14 13:01:56.102	cmrkb3cy40000y9h6lftwhcie
cmrknum1d00tn4hlefq5np8je	A2992	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:56.113	2026-07-14 13:01:56.113	cmrknujxm000b4hle4o2fwrvs
cmrknum1n00tp4hleqq47e0dn	N55S	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:56.123	2026-07-14 13:01:56.123	cmrknujxm000b4hle4o2fwrvs
cmrknum2h00tr4hle9kh230og	REDMI WATCH 5 LITE	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:56.153	2026-07-14 13:01:56.153	cmrknujwz00044hle5lxikvcu
cmrknum2n00tt4hleuip5f2ys	THINKPAD	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:01:56.16	2026-07-14 13:01:56.16	cmrknujxm000b4hle4o2fwrvs
cmrknum2u00tv4hletreukfvm	XPAW015	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:56.166	2026-07-14 13:01:56.166	cmrknujwz00044hle5lxikvcu
cmrknum3000tx4hle4pqca0wo	A3296	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:56.172	2026-07-14 13:01:56.172	cmrkb3cy40000y9h6lftwhcie
cmrknum3700tz4hlerd5hf1hu	TA-1234	cmrknuk1s001i4hleqifj4gnr	2026-07-14 13:01:56.179	2026-07-14 13:01:56.179	cmrkb3cy40000y9h6lftwhcie
cmrknum3e00u14hlev4ningbh	UA46F5550	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:56.186	2026-07-14 13:01:56.186	cmrknujy0000g4hleg9xefyth
cmrknum3k00u34hlelwoa12ez	SM-M315F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:56.193	2026-07-14 13:01:56.193	cmrkb3cy40000y9h6lftwhcie
cmrknum3r00u54hleevw0zp8v	MATE VIEW GT	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:56.2	2026-07-14 13:01:56.2	cmrknujxu000e4hle1dgnvong
cmrknum3y00u74hle9cjbihih	SM-L310	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:56.206	2026-07-14 13:01:56.206	cmrknujwz00044hle5lxikvcu
cmrknum4400u94hle5h0g3m8t	POCO X7 PRO 5G	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:56.213	2026-07-14 13:01:56.213	cmrkb3cy40000y9h6lftwhcie
cmrknum4b00ub4hlebtnc0mqq	SM-A605F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:56.219	2026-07-14 13:01:56.219	cmrkb3cy40000y9h6lftwhcie
cmrknum4i00ud4hlevn051ugo	GTS1	cmrknuk1k001g4hlenhg99g16	2026-07-14 13:01:56.226	2026-07-14 13:01:56.226	cmrknujwz00044hle5lxikvcu
cmrknum4p00uf4hlen948vj0o	BIP GLOBAL	cmrknuk1k001g4hlenhg99g16	2026-07-14 13:01:56.233	2026-07-14 13:01:56.233	cmrknujwz00044hle5lxikvcu
cmrknum4w00uh4hleqzotia07	REDMI WATCH 3	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:56.24	2026-07-14 13:01:56.24	cmrknujwz00044hle5lxikvcu
cmrknum5300uj4hleoyzdokt0	A142	cmrknuk0e00144hlema8gy8pv	2026-07-14 13:01:56.247	2026-07-14 13:01:56.247	cmrkb3cy40000y9h6lftwhcie
cmrknum5b00ul4hlelp6c4bpr	REDMI 10 POWER	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:56.255	2026-07-14 13:01:56.255	cmrkb3cy40000y9h6lftwhcie
cmrknum5l00un4hlen87qv8ro	A1969	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:56.265	2026-07-14 13:01:56.265	cmrknujwz00044hle5lxikvcu
cmrknum5t00up4hleun6p8e5o	X1503Z	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:56.273	2026-07-14 13:01:56.273	cmrknujxm000b4hle4o2fwrvs
cmrknum6100ur4hlehfjzmga5	JAT-L29	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:56.281	2026-07-14 13:01:56.281	cmrkb3cy40000y9h6lftwhcie
cmrknum6800ut4hle5gnees3x	BOD-WDH9	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:56.288	2026-07-14 13:01:56.288	cmrknujxm000b4hle4o2fwrvs
cmrknum6h00uv4hle8nfbt468	REALME 7I	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:56.297	2026-07-14 13:01:56.297	cmrkb3cy40000y9h6lftwhcie
cmrknum6o00ux4hlexr1ejygs	WATCH S1	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:56.305	2026-07-14 13:01:56.305	cmrknujwz00044hle5lxikvcu
cmrknum6y00uz4hleohdkgawo	3160NGW	cmrknujz9000s4hleu8mshqu7	2026-07-14 13:01:56.314	2026-07-14 13:01:56.314	cmrknujx800074hlexsapxr4z
cmrknum7700v14hledt2k1bv2	A2018	cmrknuk1k001g4hlenhg99g16	2026-07-14 13:01:56.323	2026-07-14 13:01:56.323	cmrknujwz00044hle5lxikvcu
cmrknum7g00v34hle2964opex	15-K007NE	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:01:56.332	2026-07-14 13:01:56.332	cmrknujxm000b4hle4o2fwrvs
cmrknum7n00v54hlevqf2yzyd	XG49VQ	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:56.339	2026-07-14 13:01:56.339	cmrknujxu000e4hle1dgnvong
cmrknum7v00v74hle477asuii	PCG-7161L	cmrknujyl000l4hlezisknz7b	2026-07-14 13:01:56.347	2026-07-14 13:01:56.347	cmrknujxm000b4hle4o2fwrvs
cmrknum8300v94hleyxz79j67	A1419	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:56.355	2026-07-14 13:01:56.355	cmrknujx800074hlexsapxr4z
cmrknum8b00vb4hlevai3khu7	REDMI GT MASTER	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:56.363	2026-07-14 13:01:56.363	cmrkb3cy40000y9h6lftwhcie
cmrknum8j00vd4hleg9hh878h	SM-A256E	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:56.371	2026-07-14 13:01:56.371	cmrkb3cy40000y9h6lftwhcie
cmrknum8r00vf4hle37z4ju2b	MI BAND 5	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:56.379	2026-07-14 13:01:56.379	cmrknujwz00044hle5lxikvcu
cmrknum8y00vh4hlel55idi6g	SM-R930	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:56.387	2026-07-14 13:01:56.387	cmrknujwz00044hle5lxikvcu
cmrknum9600vj4hleek8a74c5	CPH2529	cmrknuk1c001e4hleq9bl3u7w	2026-07-14 13:01:56.394	2026-07-14 13:01:56.394	cmrkb3cy40000y9h6lftwhcie
cmrknum9e00vl4hlepxkxh5qx	1872	cmrknujy4000h4hlefueee7c4	2026-07-14 13:01:56.402	2026-07-14 13:01:56.402	cmrknujxm000b4hle4o2fwrvs
cmrknum9m00vn4hle0pg9aldy	A3000-H	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:01:56.41	2026-07-14 13:01:56.41	cmrkb3cyo0001y9h6bozaifdg
cmrknum9t00vp4hle4c57adig	A3084	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:56.417	2026-07-14 13:01:56.417	cmrkb3cy40000y9h6lftwhcie
cmrknuma100vr4hle06yrtrzv	SM-A055F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:56.425	2026-07-14 13:01:56.425	cmrkb3cy40000y9h6lftwhcie
cmrknuma900vt4hle4e3h8289	L65M5-5SIN	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:56.433	2026-07-14 13:01:56.433	cmrknujy0000g4hleg9xefyth
cmrknumag00vv4hleb85u0lw8	X552L	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:56.441	2026-07-14 13:01:56.441	cmrknujxm000b4hle4o2fwrvs
cmrknumao00vx4hle3c2jn3vw	K59 PRO	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:56.448	2026-07-14 13:01:56.448	cmrknujwz00044hle5lxikvcu
cmrknumay00vz4hlehofvgzkf	A2407	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:56.458	2026-07-14 13:01:56.458	cmrkb3cy40000y9h6lftwhcie
cmrknumb600w14hle7yj0bz3t	MIBRO SMART WATCH INPUT	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:56.467	2026-07-14 13:01:56.467	cmrknujwz00044hle5lxikvcu
cmrknumbe00w34hlejq1lhnr8	A5500-H	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:01:56.475	2026-07-14 13:01:56.475	cmrkb3cyo0001y9h6bozaifdg
cmrknumbm00w54hlee8bpngkh	NOTE 20 ULTRA	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:56.482	2026-07-14 13:01:56.482	cmrkb3cy40000y9h6lftwhcie
cmrknumbu00w74hlefmxggw5d	S22Ultra	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:56.49	2026-07-14 13:01:56.49	cmrkb3cy40000y9h6lftwhcie
cmrknumc200w94hle52z96t3m	SM-G950F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:56.499	2026-07-14 13:01:56.499	cmrkb3cy40000y9h6lftwhcie
cmrknumca00wb4hlegeesljm2	ASUS-Z00AD	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:56.506	2026-07-14 13:01:56.506	cmrkb3cy40000y9h6lftwhcie
cmrknumci00wd4hlei88tuji1	B19-5ATM	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:56.515	2026-07-14 13:01:56.515	cmrknujwz00044hle5lxikvcu
cmrknumcq00wf4hlefn4hhbt1	SM-A730F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:56.522	2026-07-14 13:01:56.522	cmrkb3cy40000y9h6lftwhcie
cmrknumcz00wh4hlesfg7w5ay	SM-S721B	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:56.531	2026-07-14 13:01:56.531	cmrkb3cy40000y9h6lftwhcie
cmrknumd600wj4hlezi547hgp	SM-A105G	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:56.538	2026-07-14 13:01:56.538	cmrkb3cy40000y9h6lftwhcie
cmrknumdg00wl4hle2zeqpn9d	XT2343-6	cmrknujz5000r4hleshjq47jw	2026-07-14 13:01:56.548	2026-07-14 13:01:56.548	cmrkb3cy40000y9h6lftwhcie
cmrknumdq00wn4hle5vbrcyri	H8314	cmrknujyl000l4hlezisknz7b	2026-07-14 13:01:56.558	2026-07-14 13:01:56.558	cmrkb3cy40000y9h6lftwhcie
cmrknumdy00wp4hlexs6zcofd	VERSACE	cmrknuk2f001o4hlemtynxx0d	2026-07-14 13:01:56.567	2026-07-14 13:01:56.567	cmrknujwz00044hle5lxikvcu
cmrknume600wr4hle75mrl3ds	PIXLE  2	cmrknuk0x00194hlevg4ydqsz	2026-07-14 13:01:56.574	2026-07-14 13:01:56.574	cmrkb3cy40000y9h6lftwhcie
cmrknumee00wt4hlesdsw9ed5	SM-W727	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:56.583	2026-07-14 13:01:56.583	cmrknujxm000b4hle4o2fwrvs
cmrknumen00wv4hle66m365cg	T00G	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:56.591	2026-07-14 13:01:56.591	cmrkb3cy40000y9h6lftwhcie
cmrknumeu00wx4hlekj6lug47	SM-R900	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:56.598	2026-07-14 13:01:56.598	cmrknujwz00044hle5lxikvcu
cmrknumf200wz4hleysdgpk0a	HSN-CBA	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:56.606	2026-07-14 13:01:56.606	cmrknujxu000e4hle1dgnvong
cmrknumf900x14hle606hgihq	MIBRO WHATCH LITE 2	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:56.613	2026-07-14 13:01:56.613	cmrknujwz00044hle5lxikvcu
cmrknumfh00x34hleiivgmpuw	BLACK SHARK S1 PRO	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:56.621	2026-07-14 13:01:56.621	cmrknujwz00044hle5lxikvcu
cmrknumfq00x54hle34q061pr	PREDATOR HELIOS NEO 16	cmrknuk0500114hleha2g5pf3	2026-07-14 13:01:56.63	2026-07-14 13:01:56.63	cmrknujxm000b4hle4o2fwrvs
cmrknumfz00x74hleefbjde7n	XT2423-2	cmrknujz5000r4hleshjq47jw	2026-07-14 13:01:56.639	2026-07-14 13:01:56.639	cmrkb3cy40000y9h6lftwhcie
cmrknumg700x94hle12jr1qh3	MI 13 ULTRA	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:56.648	2026-07-14 13:01:56.648	cmrkb3cy40000y9h6lftwhcie
cmrknumgf00xb4hlerte2gc4w	A1602	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:56.655	2026-07-14 13:01:56.655	cmrknujxx000f4hle4jp78rc5
cmrknumgn00xd4hlenvawmh6j	SM-T705	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:56.663	2026-07-14 13:01:56.663	cmrkb3cyo0001y9h6bozaifdg
cmrknumgu00xf4hle1ou772wp	XT2117-4	cmrknujz5000r4hleshjq47jw	2026-07-14 13:01:56.67	2026-07-14 13:01:56.67	cmrkb3cy40000y9h6lftwhcie
cmrknumh400xh4hlei9xrt09v	SM-R940	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:56.68	2026-07-14 13:01:56.68	cmrknujwz00044hle5lxikvcu
cmrknumhc00xj4hlewmvpkla4	A2442	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:56.688	2026-07-14 13:01:56.688	cmrknujxm000b4hle4o2fwrvs
cmrknumhk00xl4hleswi95lw3	A2170	cmrknuk1k001g4hlenhg99g16	2026-07-14 13:01:56.696	2026-07-14 13:01:56.696	cmrknujwz00044hle5lxikvcu
cmrknumhs00xn4hleqjh0fjwg	SM-T280	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:56.704	2026-07-14 13:01:56.704	cmrkb3cyo0001y9h6bozaifdg
cmrknumi200xp4hle895q2mpz	REDMI NOTE 14S	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:56.714	2026-07-14 13:01:56.714	cmrkb3cy40000y9h6lftwhcie
cmrknumi900xr4hle1d21jm9j	GT-P6800	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:56.721	2026-07-14 13:01:56.721	cmrkb3cyo0001y9h6bozaifdg
cmrknumih00xt4hlewlqrjfhq	XT2347-2	cmrknujz5000r4hleshjq47jw	2026-07-14 13:01:56.729	2026-07-14 13:01:56.729	cmrkb3cy40000y9h6lftwhcie
cmrknumio00xv4hleruawc2it	KIESLECT KS2	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:56.736	2026-07-14 13:01:56.736	cmrknujwz00044hle5lxikvcu
cmrknumiv00xx4hle7sva3xfz	6399	cmrknujy4000h4hlefueee7c4	2026-07-14 13:01:56.743	2026-07-14 13:01:56.743	cmrknujxm000b4hle4o2fwrvs
cmrknumj200xz4hle4fc7tcqd	REDMI NOTE 14 4G	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:56.75	2026-07-14 13:01:56.75	cmrkb3cy40000y9h6lftwhcie
cmrknumja00y14hle9o54seiw	V230IC	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:56.758	2026-07-14 13:01:56.758	cmrknujx800074hlexsapxr4z
cmrknumji00y34hleadq6trva	SM-A217F	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:56.766	2026-07-14 13:01:56.766	cmrkb3cy40000y9h6lftwhcie
cmrknumjp00y54hlestd94a4q	َA1419	cmrknuk0900124hled5cyqa39	2026-07-14 13:01:56.773	2026-07-14 13:01:56.773	cmrknujx800074hlexsapxr4z
cmrknumjw00y74hle8j5lfnlp	A2083	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:56.781	2026-07-14 13:01:56.781	cmrknujxx000f4hle4jp78rc5
cmrknumk400y94hlemwpot822	C40-30	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:01:56.788	2026-07-14 13:01:56.788	cmrknujx800074hlexsapxr4z
cmrknumkc00yb4hle1njwsc79	C40-30 (مانیتور)	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:01:56.796	2026-07-14 13:01:56.796	cmrknujxu000e4hle1dgnvong
cmrknumkp00yd4hle5ewdelkw	WATCH 2 PRO	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:56.81	2026-07-14 13:01:56.81	cmrknujwz00044hle5lxikvcu
cmrknumkx00yf4hlechmrlndw	LENOVO LEGION 5	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:01:56.817	2026-07-14 13:01:56.817	cmrknujxm000b4hle4o2fwrvs
cmrknuml400yh4hle49kzpwn6	REDMI WATCH 2 LITE	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:56.824	2026-07-14 13:01:56.824	cmrknujwz00044hle5lxikvcu
cmrknumlc00yj4hlecifwdi7b	SM-J700F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:56.832	2026-07-14 13:01:56.832	cmrkb3cy40000y9h6lftwhcie
cmrknumli00yl4hlemunsjw66	SM-N910P	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:56.839	2026-07-14 13:01:56.839	cmrkb3cy40000y9h6lftwhcie
cmrknumlr00yn4hler2bw8bfp	A2186	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:56.847	2026-07-14 13:01:56.847	cmrknujxm000b4hle4o2fwrvs
cmrknumly00yp4hleyvn9mroy	A2186 (موبایل)	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:56.854	2026-07-14 13:01:56.854	cmrkb3cy40000y9h6lftwhcie
cmrknumma00yr4hleujvdzw6f	A1971	cmrknuk1k001g4hlenhg99g16	2026-07-14 13:01:56.866	2026-07-14 13:01:56.866	cmrknujwz00044hle5lxikvcu
cmrknummi00yt4hleuo212m1n	XMMNTWQ34	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:56.874	2026-07-14 13:01:56.874	cmrknujxu000e4hle1dgnvong
cmrknummq00yv4hlexsd8q4re	LS20H315B PLUS	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:56.882	2026-07-14 13:01:56.882	cmrknujxu000e4hle1dgnvong
cmrknummy00yx4hletupwjz5h	REDMI 13 4G	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:56.89	2026-07-14 13:01:56.89	cmrkb3cy40000y9h6lftwhcie
cmrknumn600yz4hlei6gzx297	STYTJ05ZHMHW	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:56.898	2026-07-14 13:01:56.898	cmrknujxc00084hleb13o6z4a
cmrknumnd00z14hle4len328j	TREX 2	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:56.905	2026-07-14 13:01:56.905	cmrknujwz00044hle5lxikvcu
cmrknumnl00z34hleppk404yp	A2176	cmrknuk1k001g4hlenhg99g16	2026-07-14 13:01:56.913	2026-07-14 13:01:56.913	cmrknujwz00044hle5lxikvcu
cmrknumns00z54hlegeodxdc4	MJSTG1	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:56.921	2026-07-14 13:01:56.921	cmrknujxc00084hleb13o6z4a
cmrknumo100z74hledkotu0tt	REDMI NOTE 11E	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:56.929	2026-07-14 13:01:56.929	cmrkb3cy40000y9h6lftwhcie
cmrknumo800z94hlepd1vxhar	OPM1100	cmrknujzy000z4hlef0vui8me	2026-07-14 13:01:56.937	2026-07-14 13:01:56.937	cmrkb3cy40000y9h6lftwhcie
cmrknumoh00zb4hle65fmrq2a	161201	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:56.945	2026-07-14 13:01:56.945	cmrknujxm000b4hle4o2fwrvs
cmrknumoo00zd4hleivectygs	A2316	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:56.952	2026-07-14 13:01:56.952	cmrkb3cyo0001y9h6bozaifdg
cmrknumow00zf4hlenrg4b9fa	SM-A600G	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:56.96	2026-07-14 13:01:56.96	cmrkb3cy40000y9h6lftwhcie
cmrknump400zh4hle21gytbup	A2323	cmrknuk1k001g4hlenhg99g16	2026-07-14 13:01:56.968	2026-07-14 13:01:56.968	cmrknujwz00044hle5lxikvcu
cmrknumpc00zj4hle0a8xgv50	ALI-NX1	cmrknujyo000m4hlecl948w9e	2026-07-14 13:01:56.976	2026-07-14 13:01:56.976	cmrkb3cy40000y9h6lftwhcie
cmrknumpk00zl4hle3ffixuld	GTR 3	cmrknuk1k001g4hlenhg99g16	2026-07-14 13:01:56.984	2026-07-14 13:01:56.984	cmrknujwz00044hle5lxikvcu
cmrknumpr00zn4hleitg5jhew	EliteBook 840 G3	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:01:56.992	2026-07-14 13:01:56.992	cmrknujxm000b4hle4o2fwrvs
cmrknumpz00zp4hlealkkqpzq	A3287	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:56.999	2026-07-14 13:01:56.999	cmrkb3cy40000y9h6lftwhcie
cmrknumq700zr4hle2sligsyy	LG-W280	cmrknuk0p00174hleoejfscfb	2026-07-14 13:01:57.007	2026-07-14 13:01:57.007	cmrknujwz00044hle5lxikvcu
cmrknumqe00zt4hlezjw6iasz	B105	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:57.014	2026-07-14 13:01:57.014	cmrknujxc00084hleb13o6z4a
cmrknumql00zv4hlea81d12iz	SM-N976B	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:57.022	2026-07-14 13:01:57.022	cmrkb3cy40000y9h6lftwhcie
cmrknumqt00zx4hle9jj72r9b	A2275	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:57.029	2026-07-14 13:01:57.029	cmrkb3cy40000y9h6lftwhcie
cmrknumr000zz4hle19sqflmw	TIA-B09	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:57.036	2026-07-14 13:01:57.036	cmrknujwz00044hle5lxikvcu
cmrknumr701014hlezz4wr5ed	PIXLE 6 PRO	cmrknuk0x00194hlevg4ydqsz	2026-07-14 13:01:57.043	2026-07-14 13:01:57.043	cmrkb3cy40000y9h6lftwhcie
cmrknumre01034hle3sa6fbtc	SDJQR02RR	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:57.05	2026-07-14 13:01:57.05	cmrknujxc00084hleb13o6z4a
cmrknumrl01054hlexsqt3uxx	A2013	cmrknuk1k001g4hlenhg99g16	2026-07-14 13:01:57.057	2026-07-14 13:01:57.057	cmrknujwz00044hle5lxikvcu
cmrknumrs01074hle56o3hw8l	XT2027	cmrknujz5000r4hleshjq47jw	2026-07-14 13:01:57.064	2026-07-14 13:01:57.064	cmrkb3cy40000y9h6lftwhcie
cmrknumry01094hleeco5an5y	A2021	cmrknuk1k001g4hlenhg99g16	2026-07-14 13:01:57.07	2026-07-14 13:01:57.07	cmrknujwz00044hle5lxikvcu
cmrknums5010b4hlefhz4gv9m	XT2231	cmrknujz5000r4hleshjq47jw	2026-07-14 13:01:57.077	2026-07-14 13:01:57.077	cmrkb3cy40000y9h6lftwhcie
cmrknumsa010d4hleb4wkrcun	TA-1205	cmrknuk1s001i4hleqifj4gnr	2026-07-14 13:01:57.082	2026-07-14 13:01:57.082	cmrkb3cy40000y9h6lftwhcie
cmrknumse010f4hlepugb0ne1	MI BAND 7 PRO	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:57.086	2026-07-14 13:01:57.086	cmrknujwz00044hle5lxikvcu
cmrknumsi010h4hlehs8tq94p	S-052694	cmrknuk1f001f4hle4qdiojps	2026-07-14 13:01:57.091	2026-07-14 13:01:57.091	cmrkb3cy40000y9h6lftwhcie
cmrknumsm010j4hlezr664yuk	XPAW011	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:57.094	2026-07-14 13:01:57.094	cmrknujwz00044hle5lxikvcu
cmrknumsq010l4hlezmugcade	A2141	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:57.098	2026-07-14 13:01:57.098	cmrknujxm000b4hle4o2fwrvs
cmrknumsu010n4hlebx7uaij6	EML-AL00	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:57.102	2026-07-14 13:01:57.102	cmrkb3cy40000y9h6lftwhcie
cmrknumsy010p4hleqj1olln6	MIBRO SMART WATCH FCC	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:57.106	2026-07-14 13:01:57.106	cmrknujwz00044hle5lxikvcu
cmrknumt2010r4hle6f5trrio	A2215	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:57.111	2026-07-14 13:01:57.111	cmrknujwz00044hle5lxikvcu
cmrknumt6010t4hleobp76j74	PIXLE 7	cmrknuk0x00194hlevg4ydqsz	2026-07-14 13:01:57.114	2026-07-14 13:01:57.114	cmrkb3cy40000y9h6lftwhcie
cmrknumta010v4hle9lxn2w69	M2 PRO	cmrknuk0100104hle0biwkdw8	2026-07-14 13:01:57.118	2026-07-14 13:01:57.118	cmrknujwz00044hle5lxikvcu
cmrknumte010x4hles529vu53	SM-T295	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:57.122	2026-07-14 13:01:57.122	cmrkb3cy40000y9h6lftwhcie
cmrknumtl010z4hlez4jljo8m	A2220	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:57.129	2026-07-14 13:01:57.129	cmrkb3cy40000y9h6lftwhcie
cmrknumtt01114hles8vtcco9	VID-B19	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:57.137	2026-07-14 13:01:57.137	cmrknujwz00044hle5lxikvcu
cmrknumtz01134hlet2f63w5x	A-022033	cmrknuk1f001f4hle4qdiojps	2026-07-14 13:01:57.143	2026-07-14 13:01:57.143	cmrkb3cy40000y9h6lftwhcie
cmrknumu301154hlexg0d3ge2	ENVY 27	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:01:57.147	2026-07-14 13:01:57.147	cmrknujx800074hlexsapxr4z
cmrknumu701174hle7uxmwysd	SERIES 8	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:57.151	2026-07-14 13:01:57.151	cmrknujwz00044hle5lxikvcu
cmrknumub01194hlet2hf98x2	XT2321-3	cmrknujz5000r4hleshjq47jw	2026-07-14 13:01:57.155	2026-07-14 13:01:57.155	cmrkb3cy40000y9h6lftwhcie
cmrknumuf011b4hlei9lznfna	GT5 PRO	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:57.16	2026-07-14 13:01:57.16	cmrknujwz00044hle5lxikvcu
cmrknumuj011d4hlegt1kueh9	PIXLE 7 PRO	cmrknuk0x00194hlevg4ydqsz	2026-07-14 13:01:57.163	2026-07-14 13:01:57.163	cmrkb3cy40000y9h6lftwhcie
cmrknumun011f4hlex8w5dk67	NOTE 9 S	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:57.167	2026-07-14 13:01:57.167	cmrkb3cy40000y9h6lftwhcie
cmrknumuq011h4hle0lwz767v	SM-M305F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:57.171	2026-07-14 13:01:57.171	cmrkb3cy40000y9h6lftwhcie
cmrknumuu011j4hleaj6kniri	SM-M526B	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:57.174	2026-07-14 13:01:57.174	cmrkb3cy40000y9h6lftwhcie
cmrknumuy011l4hleqgz6v7s7	SM-P605	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:57.178	2026-07-14 13:01:57.178	cmrkb3cyo0001y9h6bozaifdg
cmrknumv2011n4hlezxl1te6v	SM-E135F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:57.182	2026-07-14 13:01:57.182	cmrkb3cy40000y9h6lftwhcie
cmrknumv6011p4hle12s9zid2	SM-A047F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:57.186	2026-07-14 13:01:57.186	cmrkb3cy40000y9h6lftwhcie
cmrknumva011r4hlec4d2xxqo	SM-A057F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:57.19	2026-07-14 13:01:57.19	cmrkb3cy40000y9h6lftwhcie
cmrknumvf011t4hlezeuqtrs9	SM-057F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:57.195	2026-07-14 13:01:57.195	cmrkb3cy40000y9h6lftwhcie
cmrknumvk011v4hledmldp0j9	MI BAND 6	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:57.2	2026-07-14 13:01:57.2	cmrknujwz00044hle5lxikvcu
cmrknumvp011x4hleixq7tx5x	BE24A	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:57.205	2026-07-14 13:01:57.205	cmrknujxu000e4hle1dgnvong
cmrknumvu011z4hlefyk894kp	STYTJ02ZHM	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:57.211	2026-07-14 13:01:57.211	cmrknujxc00084hleb13o6z4a
cmrknumvz01214hleywkprwlp	REALME C11	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:57.216	2026-07-14 13:01:57.216	cmrkb3cy40000y9h6lftwhcie
cmrknumw301234hle2dr4m9ql	14-ES0013DX	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:01:57.22	2026-07-14 13:01:57.22	cmrknujxm000b4hle4o2fwrvs
cmrknumw801254hleyn120roj	E6833	cmrknujyl000l4hlezisknz7b	2026-07-14 13:01:57.224	2026-07-14 13:01:57.224	cmrkb3cy40000y9h6lftwhcie
cmrknumwc01274hlesp9loifj	TA-1021	cmrknuk1s001i4hleqifj4gnr	2026-07-14 13:01:57.228	2026-07-14 13:01:57.228	cmrkb3cy40000y9h6lftwhcie
cmrknumwg01294hlecj6msekp	A1673	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:57.232	2026-07-14 13:01:57.232	cmrkb3cyo0001y9h6bozaifdg
cmrknumwj012b4hleuls9ncoc	A514-65G-75CC	cmrknuk0500114hleha2g5pf3	2026-07-14 13:01:57.236	2026-07-14 13:01:57.236	cmrknujxm000b4hle4o2fwrvs
cmrknumwo012d4hlef041ddgy	MI BAND 7	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:57.24	2026-07-14 13:01:57.24	cmrknujwz00044hle5lxikvcu
cmrknumws012f4hlenzrif5fg	SM-A526B	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:57.245	2026-07-14 13:01:57.245	cmrkb3cy40000y9h6lftwhcie
cmrknumwx012h4hleuq5ry196	SGA-B19	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:57.249	2026-07-14 13:01:57.249	cmrknujwz00044hle5lxikvcu
cmrknumx1012j4hlefb4tzuh1	TA_1341	cmrknuk1s001i4hleqifj4gnr	2026-07-14 13:01:57.254	2026-07-14 13:01:57.254	cmrkb3cy40000y9h6lftwhcie
cmrknumx8012l4hle2mguo17i	TP00069A	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:01:57.26	2026-07-14 13:01:57.26	cmrknujxm000b4hle4o2fwrvs
cmrknumxe012n4hle2poqi6wz	MI PAD 3	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:57.266	2026-07-14 13:01:57.266	cmrkb3cyo0001y9h6bozaifdg
cmrknumxl012p4hleuuy9tw8k	TREX PRO	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:57.273	2026-07-14 13:01:57.273	cmrknujwz00044hle5lxikvcu
cmrknumxs012r4hle2otjk8vs	PIXLE 8	cmrknuk0x00194hlevg4ydqsz	2026-07-14 13:01:57.281	2026-07-14 13:01:57.281	cmrkb3cy40000y9h6lftwhcie
cmrknumy0012t4hle3w3w5mfd	DUB-LX3	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:57.288	2026-07-14 13:01:57.288	cmrkb3cy40000y9h6lftwhcie
cmrknumy7012v4hlexu266dka	REALME C21	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:57.295	2026-07-14 13:01:57.295	cmrkb3cy40000y9h6lftwhcie
cmrknumye012x4hlefstjbc6y	XT2095	cmrknujz5000r4hleshjq47jw	2026-07-14 13:01:57.302	2026-07-14 13:01:57.302	cmrkb3cy40000y9h6lftwhcie
cmrknumym012z4hlenmrjme6j	V1	cmrknujyw000o4hlee6zipn1g	2026-07-14 13:01:57.31	2026-07-14 13:01:57.31	cmrkb3cy40000y9h6lftwhcie
cmrknumys01314hleilwxf4tt	ZE551ML	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:57.317	2026-07-14 13:01:57.317	cmrkb3cy40000y9h6lftwhcie
cmrknumyz01334hleloqz20ui	13PRO MAX	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:57.323	2026-07-14 13:01:57.323	cmrkb3cy40000y9h6lftwhcie
cmrknumz701354hleh11umvdi	1796	cmrknujy4000h4hlefueee7c4	2026-07-14 13:01:57.331	2026-07-14 13:01:57.331	cmrknujxm000b4hle4o2fwrvs
cmrknumze01374hleauohsj2g	XPAW005	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:57.338	2026-07-14 13:01:57.338	cmrknujwz00044hle5lxikvcu
cmrknumzm01394hlehmlm6vxk	LTN-B19	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:57.346	2026-07-14 13:01:57.346	cmrknujwz00044hle5lxikvcu
cmrknumzt013b4hle8xppgf6r	BLACK SHARK 5	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:57.354	2026-07-14 13:01:57.354	cmrkb3cy40000y9h6lftwhcie
cmrknun01013d4hlemsgefjes	MI BAND 3	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:57.361	2026-07-14 13:01:57.361	cmrknujwz00044hle5lxikvcu
cmrknun07013f4hle48csotd7	MIBRO C3	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:57.368	2026-07-14 13:01:57.368	cmrknujwz00044hle5lxikvcu
cmrknun0f013h4hlewcyecrdm	HK two	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:57.375	2026-07-14 13:01:57.375	cmrknujwz00044hle5lxikvcu
cmrknun0n013j4hlezm6po0m7	SM-R810	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:57.384	2026-07-14 13:01:57.384	cmrknujwz00044hle5lxikvcu
cmrknun0v013l4hle18s4z2o5	A78 4G	cmrknuk1c001e4hleq9bl3u7w	2026-07-14 13:01:57.391	2026-07-14 13:01:57.391	cmrkb3cy40000y9h6lftwhcie
cmrknun12013n4hletzkcb8jj	MI BAND 8	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:57.398	2026-07-14 13:01:57.398	cmrknujwz00044hle5lxikvcu
cmrknun1b013p4hle0b3c8hag	BLACK SHARK 3	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:57.408	2026-07-14 13:01:57.408	cmrkb3cy40000y9h6lftwhcie
cmrknun1j013r4hlelevvslwu	REDMI K20 PRO	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:57.415	2026-07-14 13:01:57.415	cmrkb3cy40000y9h6lftwhcie
cmrknun1q013t4hleue34nebu	NOTHING PHONE 2A	cmrknuk0e00144hlema8gy8pv	2026-07-14 13:01:57.422	2026-07-14 13:01:57.422	cmrkb3cy40000y9h6lftwhcie
cmrknun1y013v4hle72p54sgo	HSN-114C-4	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:01:57.43	2026-07-14 13:01:57.43	cmrknujxm000b4hle4o2fwrvs
cmrknun25013x4hlete0kku31	MDZ-28-AA	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:57.437	2026-07-14 13:01:57.437	cmrknujx200054hlexj2ts9xq
cmrknun2d013z4hle8q6j384u	PCG-61315L	cmrknujyl000l4hlezisknz7b	2026-07-14 13:01:57.445	2026-07-14 13:01:57.445	cmrknujxm000b4hle4o2fwrvs
cmrknun2k01414hlesku2apbm	V2109	cmrknujzl000v4hle1n0o4b2k	2026-07-14 13:01:57.453	2026-07-14 13:01:57.453	cmrkb3cy40000y9h6lftwhcie
cmrknun2t01434hle32dd9g79	MX239	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:57.461	2026-07-14 13:01:57.461	cmrknujxu000e4hle1dgnvong
cmrknun3101454hle28dwpm6z	CRT-NX1	cmrknujyo000m4hlecl948w9e	2026-07-14 13:01:57.469	2026-07-14 13:01:57.469	cmrkb3cy40000y9h6lftwhcie
cmrknun3801474hle6wufr0ra	PIXLE 3	cmrknuk0x00194hlevg4ydqsz	2026-07-14 13:01:57.476	2026-07-14 13:01:57.476	cmrkb3cy40000y9h6lftwhcie
cmrknun3g01494hle33gouj8h	SM-F936B	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:57.484	2026-07-14 13:01:57.484	cmrkb3cy40000y9h6lftwhcie
cmrknun3n014b4hlerygrwpp6	A2040	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:57.491	2026-07-14 13:01:57.491	cmrknujwz00044hle5lxikvcu
cmrknun3u014d4hlelqvnlwmz	POCO C75	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:57.498	2026-07-14 13:01:57.498	cmrkb3cy40000y9h6lftwhcie
cmrknun41014f4hlej6hfryjh	DCO-LX9	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:57.506	2026-07-14 13:01:57.506	cmrkb3cy40000y9h6lftwhcie
cmrknun49014h4hley5syy4v9	GTR 2E	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:57.513	2026-07-14 13:01:57.513	cmrknujwz00044hle5lxikvcu
cmrknun4g014j4hleq8lz6omz	SVD112A1SM	cmrknujyl000l4hlezisknz7b	2026-07-14 13:01:57.52	2026-07-14 13:01:57.52	cmrknujxm000b4hle4o2fwrvs
cmrknun4o014l4hle2jlmhzl9	MS-1582	cmrknujz9000s4hleu8mshqu7	2026-07-14 13:01:57.528	2026-07-14 13:01:57.528	cmrknujxm000b4hle4o2fwrvs
cmrknun4v014n4hle7um3mjxa	LATITUDE E6400	cmrknujzd000t4hle1ujh33no	2026-07-14 13:01:57.535	2026-07-14 13:01:57.535	cmrknujxm000b4hle4o2fwrvs
cmrknun53014p4hletsoecm50	XT 2097	cmrknujz5000r4hleshjq47jw	2026-07-14 13:01:57.543	2026-07-14 13:01:57.543	cmrkb3cy40000y9h6lftwhcie
cmrknun5a014r4hlecwn2msr5	15-EC2150AX	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:01:57.55	2026-07-14 13:01:57.55	cmrknujxm000b4hle4o2fwrvs
cmrknun5i014t4hlelm69zl0h	SM-X210	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:57.558	2026-07-14 13:01:57.558	cmrkb3cyo0001y9h6bozaifdg
cmrknun5p014v4hleoha6gz9c	XPAW004	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:57.565	2026-07-14 13:01:57.565	cmrknujwz00044hle5lxikvcu
cmrknun5x014x4hle8ankmnjl	M3500Q	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:57.573	2026-07-14 13:01:57.573	cmrknujxm000b4hle4o2fwrvs
cmrknun64014z4hleitwsavvq	PIXEL 7PRO	cmrknuk0x00194hlevg4ydqsz	2026-07-14 13:01:57.58	2026-07-14 13:01:57.58	cmrkb3cy40000y9h6lftwhcie
cmrknun6b01514hle3stvfykg	MIL-B19	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:57.587	2026-07-14 13:01:57.587	cmrknujwz00044hle5lxikvcu
cmrknun6i01534hlectt9e6sw	ZB601KL	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:57.594	2026-07-14 13:01:57.594	cmrkb3cy40000y9h6lftwhcie
cmrknun6q01554hle9p08m1uc	MNS-B19	cmrknuk2j001p4hle30dknop3	2026-07-14 13:01:57.602	2026-07-14 13:01:57.602	cmrknujwz00044hle5lxikvcu
cmrknun6x01574hle888a87ov	A063	cmrknuk0e00144hlema8gy8pv	2026-07-14 13:01:57.609	2026-07-14 13:01:57.609	cmrkb3cy40000y9h6lftwhcie
cmrknun7301594hlevpcl8gw3	SM-R830	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:57.616	2026-07-14 13:01:57.616	cmrknujwz00044hle5lxikvcu
cmrknun7b015b4hlevmoy9dws	B105	cmrknuk2p001r4hle44rgi0fl	2026-07-14 13:01:57.623	2026-07-14 13:01:57.623	cmrknujxc00084hleb13o6z4a
cmrknun7j015d4hle5a5bt8qh	GX7AS	cmrknuk0x00194hlevg4ydqsz	2026-07-14 13:01:57.631	2026-07-14 13:01:57.631	cmrkb3cy40000y9h6lftwhcie
cmrknun7r015f4hleib6x5du5	XPAW002	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:57.64	2026-07-14 13:01:57.64	cmrknujwz00044hle5lxikvcu
cmrknun80015h4hle4279jm05	BE2029	cmrknuk1a001d4hles4vy8kk2	2026-07-14 13:01:57.648	2026-07-14 13:01:57.648	cmrkb3cy40000y9h6lftwhcie
cmrknun87015j4hlef3ux2s6m	SM-S901E	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:57.655	2026-07-14 13:01:57.655	cmrkb3cy40000y9h6lftwhcie
cmrknun8f015l4hlefyw3g7fw	xiaomi Redmi 12 kalvo	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:57.663	2026-07-14 13:01:57.663	cmrkb3cy40000y9h6lftwhcie
cmrknun8m015n4hlewodpc8tz	VOSTRO-1015	cmrknujzd000t4hle1ujh33no	2026-07-14 13:01:57.67	2026-07-14 13:01:57.67	cmrknujxm000b4hle4o2fwrvs
cmrknun8t015p4hle5fxd3vjj	A2403	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:57.677	2026-07-14 13:01:57.677	cmrkb3cy40000y9h6lftwhcie
cmrknun90015r4hlebs2b5zmt	AMZFIT TREX	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:57.684	2026-07-14 13:01:57.684	cmrknujwz00044hle5lxikvcu
cmrknun9b015t4hlemr38qogq	A2849	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:57.695	2026-07-14 13:01:57.695	cmrkb3cy40000y9h6lftwhcie
cmrknun9j015v4hleykcr4weu	A2783	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:57.703	2026-07-14 13:01:57.703	cmrkb3cy40000y9h6lftwhcie
cmrknun9r015x4hle3ikefl0j	HUAWEI GRA - UL00	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:57.711	2026-07-14 13:01:57.711	cmrkb3cy40000y9h6lftwhcie
cmrknun9y015z4hleuwwbwpl2	A2097	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:57.718	2026-07-14 13:01:57.718	cmrkb3cy40000y9h6lftwhcie
cmrknuna601614hley7a0ik20	XT1924-1	cmrknujz5000r4hleshjq47jw	2026-07-14 13:01:57.726	2026-07-14 13:01:57.726	cmrkb3cy40000y9h6lftwhcie
cmrknunad01634hleljk04hw6	NOTHING PHONE 2	cmrknuk0e00144hlema8gy8pv	2026-07-14 13:01:57.733	2026-07-14 13:01:57.733	cmrkb3cy40000y9h6lftwhcie
cmrknunak01654hle1hpijeoq	AGS6-W00	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:57.74	2026-07-14 13:01:57.74	cmrkb3cyo0001y9h6bozaifdg
cmrknunar01674hlepukwerbe	A3293	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:57.747	2026-07-14 13:01:57.747	cmrkb3cy40000y9h6lftwhcie
cmrknunaz01694hlew8imf4za	REA-NX9	cmrknujyo000m4hlecl948w9e	2026-07-14 13:01:57.755	2026-07-14 13:01:57.755	cmrkb3cy40000y9h6lftwhcie
cmrknunb6016b4hleq54d09k5	GT-P6200	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:57.762	2026-07-14 13:01:57.762	cmrkb3cyo0001y9h6bozaifdg
cmrknunbd016d4hle6sq18wq9	A015	cmrknuk0e00144hlema8gy8pv	2026-07-14 13:01:57.769	2026-07-14 13:01:57.769	cmrkb3cy40000y9h6lftwhcie
cmrknunbl016f4hleybyj0r68	SM-X115	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:57.777	2026-07-14 13:01:57.777	cmrkb3cyo0001y9h6bozaifdg
cmrknunbs016h4hleox6568br	REDMI 10 2022	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:57.784	2026-07-14 13:01:57.784	cmrkb3cy40000y9h6lftwhcie
cmrknunbz016j4hlerc8ownba	GEM-701L	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:57.791	2026-07-14 13:01:57.791	cmrkb3cy40000y9h6lftwhcie
cmrknunc6016l4hleibirmmwl	MX17	cmrknuk22001k4hlewvssmg0i	2026-07-14 13:01:57.799	2026-07-14 13:01:57.799	cmrknujxm000b4hle4o2fwrvs
cmrknunce016n4hlexhz2gz8p	INSPIRON 1564	cmrknujzd000t4hle1ujh33no	2026-07-14 13:01:57.806	2026-07-14 13:01:57.806	cmrknujxm000b4hle4o2fwrvs
cmrknuncl016p4hlehaph8ami	A2215	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:57.813	2026-07-14 13:01:57.813	cmrkb3cy40000y9h6lftwhcie
cmrknuncs016r4hlesbt036xz	SM-A235F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:57.82	2026-07-14 13:01:57.82	cmrkb3cy40000y9h6lftwhcie
cmrknuncz016t4hleims8z1ns	OPL3100	cmrknujzy000z4hlef0vui8me	2026-07-14 13:01:57.827	2026-07-14 13:01:57.827	cmrkb3cy40000y9h6lftwhcie
cmrknund6016v4hle9tsy6gio	EB-BA520ABE	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:57.834	2026-07-14 13:01:57.834	cmrkb3cy40000y9h6lftwhcie
cmrknunde016x4hle29gsc25v	XT1635-03	cmrknujz5000r4hleshjq47jw	2026-07-14 13:01:57.842	2026-07-14 13:01:57.842	cmrkb3cy40000y9h6lftwhcie
cmrknundm016z4hle2kzcchs7	XT2013-2	cmrknujz5000r4hleshjq47jw	2026-07-14 13:01:57.85	2026-07-14 13:01:57.85	cmrkb3cy40000y9h6lftwhcie
cmrknundv01714hlecqg4qh6i	PRO X2 612	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:01:57.859	2026-07-14 13:01:57.859	cmrknujxm000b4hle4o2fwrvs
cmrknune101734hle1zg85e4r	PRO X2 612 G2	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:01:57.866	2026-07-14 13:01:57.866	cmrkb3cyo0001y9h6bozaifdg
cmrknune801754hlezn7jrt5j	REALME GT MASTER	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:57.872	2026-07-14 13:01:57.872	cmrkb3cy40000y9h6lftwhcie
cmrknuneg01774hlej1vue1jp	A1980	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:57.88	2026-07-14 13:01:57.88	cmrkb3cyo0001y9h6bozaifdg
cmrknunen01794hle83fkce4s	XT1926-6	cmrknujz5000r4hleshjq47jw	2026-07-14 13:01:57.887	2026-07-14 13:01:57.887	cmrkb3cy40000y9h6lftwhcie
cmrknunew017b4hleg9ud0pqp	XT2075	cmrknujz5000r4hleshjq47jw	2026-07-14 13:01:57.896	2026-07-14 13:01:57.896	cmrkb3cy40000y9h6lftwhcie
cmrknunf4017d4hleyahxljag	COMPAQ600PORO	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:01:57.904	2026-07-14 13:01:57.904	cmrknujx800074hlexsapxr4z
cmrknunfd017f4hle2tq7978v	A1897	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:57.913	2026-07-14 13:01:57.913	cmrkb3cy40000y9h6lftwhcie
cmrknunfk017h4hleirfcsgke	SM-A013F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:57.92	2026-07-14 13:01:57.92	cmrkb3cy40000y9h6lftwhcie
cmrknunfs017j4hle28yvywv6	SM-R820	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:57.928	2026-07-14 13:01:57.928	cmrknujwz00044hle5lxikvcu
cmrknunfz017l4hle2etnq67q	A3X	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:57.935	2026-07-14 13:01:57.935	cmrkb3cy40000y9h6lftwhcie
cmrknung7017n4hleej9wufua	REDMI NOTE 10 PRO 5G	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:57.943	2026-07-14 13:01:57.943	cmrkb3cy40000y9h6lftwhcie
cmrknungg017p4hle561bj3cf	TA-1334	cmrknuk1s001i4hleqifj4gnr	2026-07-14 13:01:57.952	2026-07-14 13:01:57.952	cmrkb3cy40000y9h6lftwhcie
cmrknungp017r4hle7q91hbot	Z00UD	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:57.961	2026-07-14 13:01:57.961	cmrkb3cy40000y9h6lftwhcie
cmrknungw017t4hlex12liqmv	A2296	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:57.968	2026-07-14 13:01:57.968	cmrkb3cy40000y9h6lftwhcie
cmrknunh4017v4hley6ek6waq	A1466	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:57.976	2026-07-14 13:01:57.976	cmrknujxm000b4hle4o2fwrvs
cmrknunhc017x4hlera5ty3fn	A94	cmrknuk1c001e4hleq9bl3u7w	2026-07-14 13:01:57.984	2026-07-14 13:01:57.984	cmrkb3cy40000y9h6lftwhcie
cmrknunhj017z4hle36o7gvi2	SM-A137F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:57.991	2026-07-14 13:01:57.991	cmrkb3cy40000y9h6lftwhcie
cmrknunhq01814hlezreqp0a3	15-DC0008NG	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:01:57.999	2026-07-14 13:01:57.999	cmrknujxm000b4hle4o2fwrvs
cmrknunhy01834hlejvhf2gne	SM-F946B	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:58.006	2026-07-14 13:01:58.006	cmrkb3cy40000y9h6lftwhcie
cmrknuni601854hle1zg8nr09	RKY-LX2	cmrknujyo000m4hlecl948w9e	2026-07-14 13:01:58.015	2026-07-14 13:01:58.015	cmrkb3cy40000y9h6lftwhcie
cmrknunie01874hle4tpm046d	N56J	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:58.022	2026-07-14 13:01:58.022	cmrknujxm000b4hle4o2fwrvs
cmrknunil01894hleuiwvz6wl	MS-16J9	cmrknujz9000s4hleu8mshqu7	2026-07-14 13:01:58.03	2026-07-14 13:01:58.03	cmrknujxm000b4hle4o2fwrvs
cmrknunis018b4hleeb0rfnx6	SM-M625F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:58.036	2026-07-14 13:01:58.036	cmrkb3cy40000y9h6lftwhcie
cmrknunj0018d4hler9m3oz24	A1662	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:58.044	2026-07-14 13:01:58.044	cmrkb3cy40000y9h6lftwhcie
cmrknunj7018f4hle4v04ptw8	MI CC 9	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:58.052	2026-07-14 13:01:58.052	cmrkb3cy40000y9h6lftwhcie
cmrknunjf018h4hlenc7wrbqa	پیکسل 4a فور جی	cmrknuk0x00194hlevg4ydqsz	2026-07-14 13:01:58.059	2026-07-14 13:01:58.059	cmrkb3cy40000y9h6lftwhcie
cmrknunjm018j4hle8vjq9afu	پیکسل 4a	cmrknuk0x00194hlevg4ydqsz	2026-07-14 13:01:58.066	2026-07-14 13:01:58.066	cmrkb3cy40000y9h6lftwhcie
cmrknunjt018l4hlepahbjcky	TA-1332	cmrknuk1s001i4hleqifj4gnr	2026-07-14 13:01:58.073	2026-07-14 13:01:58.073	cmrkb3cy40000y9h6lftwhcie
cmrknunk0018n4hle44tes048	GZ301Z	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:58.08	2026-07-14 13:01:58.08	cmrknujxm000b4hle4o2fwrvs
cmrknunk6018p4hleqvrxjlun	PRO TABLET 10EE G1	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:01:58.087	2026-07-14 13:01:58.087	cmrknujxm000b4hle4o2fwrvs
cmrknunkd018r4hle1bagajmm	MAO-LX9	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:58.093	2026-07-14 13:01:58.093	cmrkb3cy40000y9h6lftwhcie
cmrknunkk018t4hle5d5j54rp	2PVG200	cmrknujzy000z4hlef0vui8me	2026-07-14 13:01:58.1	2026-07-14 13:01:58.1	cmrkb3cy40000y9h6lftwhcie
cmrknunkq018v4hlesje7qh14	2pvg	cmrknujzy000z4hlef0vui8me	2026-07-14 13:01:58.106	2026-07-14 13:01:58.106	cmrkb3cy40000y9h6lftwhcie
cmrknunkv018x4hlezj7l8azh	N501V	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:58.111	2026-07-14 13:01:58.111	cmrknujxm000b4hle4o2fwrvs
cmrknunkz018z4hlebj9r1nqs	A2152	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:58.116	2026-07-14 13:01:58.116	cmrkb3cyo0001y9h6bozaifdg
cmrknunl301914hle9uptsvhc	G750-U10	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:58.119	2026-07-14 13:01:58.119	cmrkb3cy40000y9h6lftwhcie
cmrknunl601934hlerik83ygf	K52J	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:58.123	2026-07-14 13:01:58.123	cmrknujxm000b4hle4o2fwrvs
cmrknunla01954hlecce2ijms	XT2343-1	cmrknujz5000r4hleshjq47jw	2026-07-14 13:01:58.127	2026-07-14 13:01:58.127	cmrkb3cy40000y9h6lftwhcie
cmrknunle01974hleqm3ennvk	SVF142C1WW	cmrknujyl000l4hlezisknz7b	2026-07-14 13:01:58.13	2026-07-14 13:01:58.13	cmrknujxm000b4hle4o2fwrvs
cmrknunlh01994hle6tqakgg1	S860	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:01:58.134	2026-07-14 13:01:58.134	cmrkb3cy40000y9h6lftwhcie
cmrknunll019b4hleumjw1pkw	XT2019-1	cmrknujz5000r4hleshjq47jw	2026-07-14 13:01:58.138	2026-07-14 13:01:58.138	cmrkb3cy40000y9h6lftwhcie
cmrknunlp019d4hlet5xgudvq	YAL-L21	cmrknujyo000m4hlecl948w9e	2026-07-14 13:01:58.142	2026-07-14 13:01:58.142	cmrkb3cy40000y9h6lftwhcie
cmrknunlt019f4hle69k45935	X543M	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:58.145	2026-07-14 13:01:58.145	cmrknujxm000b4hle4o2fwrvs
cmrknunlx019h4hle78wrfxn3	POCO X6 5G	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:58.149	2026-07-14 13:01:58.149	cmrkb3cy40000y9h6lftwhcie
cmrknunm1019j4hleyy5egegq	REALME C35	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:58.154	2026-07-14 13:01:58.154	cmrkb3cy40000y9h6lftwhcie
cmrknunm7019l4hle708bakve	MI 12	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:58.159	2026-07-14 13:01:58.159	cmrkb3cy40000y9h6lftwhcie
cmrknunmd019n4hlev01j13is	Calling Watch Kr Pro	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:58.165	2026-07-14 13:01:58.165	cmrknujwz00044hle5lxikvcu
cmrknunmj019p4hle5jpxe7cj	SM-A526F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:58.171	2026-07-14 13:01:58.171	cmrkb3cy40000y9h6lftwhcie
cmrknunmq019r4hle44ax9nmv	I001DE	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:58.178	2026-07-14 13:01:58.178	cmrkb3cy40000y9h6lftwhcie
cmrknunmw019t4hleylawj8fy	SERIES 7	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:58.184	2026-07-14 13:01:58.184	cmrknujwz00044hle5lxikvcu
cmrknunn2019v4hle1et4otpz	IDEACENTER A340	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:01:58.19	2026-07-14 13:01:58.19	cmrknujx800074hlexsapxr4z
cmrknunn9019x4hle12x478fz	SVF153A1YL	cmrknujyl000l4hlezisknz7b	2026-07-14 13:01:58.197	2026-07-14 13:01:58.197	cmrknujxm000b4hle4o2fwrvs
cmrknunnf019z4hleasecirwg	X550C	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:58.204	2026-07-14 13:01:58.204	cmrknujxm000b4hle4o2fwrvs
cmrknunnn01a14hlelt2gddk3	SHT-AL09 (موبایل)	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:58.211	2026-07-14 13:01:58.211	cmrkb3cy40000y9h6lftwhcie
cmrknunnz01a34hleeg3ply8g	TA-1004	cmrknuk1s001i4hleqifj4gnr	2026-07-14 13:01:58.223	2026-07-14 13:01:58.223	cmrkb3cy40000y9h6lftwhcie
cmrknuno601a54hle0k4lwhqi	SM-N980F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:58.23	2026-07-14 13:01:58.23	cmrkb3cy40000y9h6lftwhcie
cmrknunod01a74hle3rfuz4bg	REDMI 5A	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:58.237	2026-07-14 13:01:58.237	cmrkb3cy40000y9h6lftwhcie
cmrknunok01a94hlea0f93cgb	PA248	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:58.244	2026-07-14 13:01:58.244	cmrknujxu000e4hle1dgnvong
cmrknunor01ab4hlen51ayqbr	A3300	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:01:58.251	2026-07-14 13:01:58.251	cmrkb3cyo0001y9h6bozaifdg
cmrknunoz01ad4hlet3gdz2mw	TPN-F104	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:01:58.26	2026-07-14 13:01:58.26	cmrknujxm000b4hle4o2fwrvs
cmrknunp601af4hlezron2if4	TFY-LX2	cmrknujyo000m4hlecl948w9e	2026-07-14 13:01:58.267	2026-07-14 13:01:58.267	cmrkb3cy40000y9h6lftwhcie
cmrknunpf01ah4hlefc4ev1y0	IDEAPAD 130-15IKB	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:01:58.275	2026-07-14 13:01:58.275	cmrknujxm000b4hle4o2fwrvs
cmrknunpn01aj4hlec9uqf21n	REDMI PAD SE	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:58.283	2026-07-14 13:01:58.283	cmrkb3cyo0001y9h6bozaifdg
cmrknunq501al4hleya4vcd1d	SM-S928B	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:58.301	2026-07-14 13:01:58.301	cmrkb3cy40000y9h6lftwhcie
cmrknunql01an4hlejdx5hm4r	STK-LX1	cmrknujyo000m4hlecl948w9e	2026-07-14 13:01:58.317	2026-07-14 13:01:58.317	cmrkb3cy40000y9h6lftwhcie
cmrknunqt01ap4hlexvpso7ky	POCO F6 PRO	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:58.325	2026-07-14 13:01:58.325	cmrkb3cy40000y9h6lftwhcie
cmrknunr001ar4hlex075l66h	PCG-81114L	cmrknujyl000l4hlezisknz7b	2026-07-14 13:01:58.333	2026-07-14 13:01:58.333	cmrknujxm000b4hle4o2fwrvs
cmrknunr801at4hletbls6irs	GT-N5100	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:58.34	2026-07-14 13:01:58.34	cmrkb3cyo0001y9h6bozaifdg
cmrknunrg01av4hlevgul51i1	T303U	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:58.349	2026-07-14 13:01:58.349	cmrknujxm000b4hle4o2fwrvs
cmrknunro01ax4hlegp0eozwa	A1429	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:58.356	2026-07-14 13:01:58.356	cmrkb3cy40000y9h6lftwhcie
cmrknunrw01az4hle3ooywz96	XT2407-1	cmrknujz5000r4hleshjq47jw	2026-07-14 13:01:58.364	2026-07-14 13:01:58.364	cmrkb3cy40000y9h6lftwhcie
cmrknuns301b14hlen2nk3u78	A91	cmrknuk1c001e4hleq9bl3u7w	2026-07-14 13:01:58.371	2026-07-14 13:01:58.371	cmrkb3cy40000y9h6lftwhcie
cmrknunsa01b34hleveimfj16	BOB-WAH9	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:58.379	2026-07-14 13:01:58.379	cmrknujxm000b4hle4o2fwrvs
cmrknunsh01b54hleiewv7hha	ELITE BOOK 850 G4	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:01:58.386	2026-07-14 13:01:58.386	cmrknujxm000b4hle4o2fwrvs
cmrknunsq01b74hlejtkn2w93	S41	cmrknujz2000q4hle3l02mekk	2026-07-14 13:01:58.394	2026-07-14 13:01:58.394	cmrkb3cy40000y9h6lftwhcie
cmrknunsy01b94hleejy0dmp2	OPAJ300	cmrknujzy000z4hlef0vui8me	2026-07-14 13:01:58.402	2026-07-14 13:01:58.402	cmrkb3cy40000y9h6lftwhcie
cmrknunt601bb4hle8otme25g	A2779	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:58.411	2026-07-14 13:01:58.411	cmrknujxm000b4hle4o2fwrvs
cmrknunte01bd4hlec3b7xnb1	REALME 12 PRO	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:58.418	2026-07-14 13:01:58.418	cmrkb3cy40000y9h6lftwhcie
cmrknuntm01bf4hledensl08i	SM-M325FV	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:58.427	2026-07-14 13:01:58.427	cmrkb3cy40000y9h6lftwhcie
cmrknuntt01bh4hlepl3063nf	XT1635-02	cmrknujz5000r4hleshjq47jw	2026-07-14 13:01:58.433	2026-07-14 13:01:58.433	cmrkb3cy40000y9h6lftwhcie
cmrknunu101bj4hlejewv8fup	TA-1196	cmrknuk1s001i4hleqifj4gnr	2026-07-14 13:01:58.441	2026-07-14 13:01:58.441	cmrkb3cy40000y9h6lftwhcie
cmrknunu901bl4hlebem8u34p	SM-T561	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:58.449	2026-07-14 13:01:58.449	cmrkb3cyo0001y9h6bozaifdg
cmrknunuk01bn4hlefw91ora5	A15S	cmrknuk1c001e4hleq9bl3u7w	2026-07-14 13:01:58.46	2026-07-14 13:01:58.46	cmrkb3cy40000y9h6lftwhcie
cmrknunur01bp4hlepwh3lmmc	SPIN 1	cmrknuk0500114hleha2g5pf3	2026-07-14 13:01:58.467	2026-07-14 13:01:58.467	cmrknujxm000b4hle4o2fwrvs
cmrknunuy01br4hle1z68xms7	ANG-LX1	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:58.474	2026-07-14 13:01:58.474	cmrkb3cy40000y9h6lftwhcie
cmrknunv601bt4hlex53odss7	K456U	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:58.482	2026-07-14 13:01:58.482	cmrknujxm000b4hle4o2fwrvs
cmrknunvd01bv4hlepdyd2mv8	A2848	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:58.489	2026-07-14 13:01:58.489	cmrkb3cy40000y9h6lftwhcie
cmrknunvl01bx4hle7w82ug45	G505	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:01:58.497	2026-07-14 13:01:58.497	cmrknujxm000b4hle4o2fwrvs
cmrknunvt01bz4hlej18xad2p	PIXLE 6A	cmrknuk0x00194hlevg4ydqsz	2026-07-14 13:01:58.505	2026-07-14 13:01:58.505	cmrkb3cy40000y9h6lftwhcie
cmrknunw101c14hle3152r5tn	XT2055-1	cmrknujz5000r4hleshjq47jw	2026-07-14 13:01:58.513	2026-07-14 13:01:58.513	cmrkb3cy40000y9h6lftwhcie
cmrknunw801c34hle9k1tiuqj	PAVILION 15	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:01:58.52	2026-07-14 13:01:58.52	cmrknujxm000b4hle4o2fwrvs
cmrknunwf01c54hlel5xsbnv5	11T PRO 5G	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:58.527	2026-07-14 13:01:58.527	cmrkb3cy40000y9h6lftwhcie
cmrknunwm01c74hlesrwvz511	REDMI NOTE 13 4G	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:58.534	2026-07-14 13:01:58.534	cmrkb3cy40000y9h6lftwhcie
cmrknunwu01c94hlejat11ccl	INSPIRON N5110	cmrknujzd000t4hle1ujh33no	2026-07-14 13:01:58.542	2026-07-14 13:01:58.542	cmrknujxm000b4hle4o2fwrvs
cmrknunx201cb4hlewk1fdw0i	M-015713	cmrknuk1f001f4hle4qdiojps	2026-07-14 13:01:58.55	2026-07-14 13:01:58.55	cmrkb3cy40000y9h6lftwhcie
cmrknunx901cd4hle1mzrru97	C-045254	cmrknuk1f001f4hle4qdiojps	2026-07-14 13:01:58.558	2026-07-14 13:01:58.558	cmrkb3cy40000y9h6lftwhcie
cmrknunxh01cf4hle2ee3lq0r	S-011375	cmrknuk1f001f4hle4qdiojps	2026-07-14 13:01:58.565	2026-07-14 13:01:58.565	cmrkb3cy40000y9h6lftwhcie
cmrknunxo01ch4hlen7hxv6dz	SM-G780G	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:58.572	2026-07-14 13:01:58.572	cmrkb3cy40000y9h6lftwhcie
cmrknunxw01cj4hlel10drbx5	SM-E236B	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:58.58	2026-07-14 13:01:58.58	cmrkb3cy40000y9h6lftwhcie
cmrknuny301cl4hlev6i70ipl	ASPIRE E1-570G	cmrknuk0500114hleha2g5pf3	2026-07-14 13:01:58.587	2026-07-14 13:01:58.587	cmrknujxm000b4hle4o2fwrvs
cmrknunyb01cn4hleuenoqjh6	MI MAX	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:58.595	2026-07-14 13:01:58.595	cmrkb3cy40000y9h6lftwhcie
cmrknunyj01cp4hleevuj8t4f	PROBOOK 440 G3	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:01:58.603	2026-07-14 13:01:58.603	cmrknujxm000b4hle4o2fwrvs
cmrknunyr01cr4hlevi2vqz1l	XT2243-1	cmrknujz5000r4hleshjq47jw	2026-07-14 13:01:58.611	2026-07-14 13:01:58.611	cmrkb3cy40000y9h6lftwhcie
cmrknunyx01ct4hle1v54o1xf	REDMI NOTE 13 PRO 4G	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:58.618	2026-07-14 13:01:58.618	cmrkb3cy40000y9h6lftwhcie
cmrknunz501cv4hleufesl6iv	AGS-W09	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:58.626	2026-07-14 13:01:58.626	cmrkb3cyo0001y9h6bozaifdg
cmrknunze01cx4hle4z8qpz9e	G525-U00	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:58.634	2026-07-14 13:01:58.634	cmrkb3cy40000y9h6lftwhcie
cmrknunzn01cz4hlehxlvplpc	A1989	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:58.643	2026-07-14 13:01:58.643	cmrknujxm000b4hle4o2fwrvs
cmrknunzv01d14hleop6yo7rj	1989	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:58.651	2026-07-14 13:01:58.651	cmrknujxm000b4hle4o2fwrvs
cmrknuo0301d34hlem5z62hpr	XT2203-1	cmrknujz5000r4hleshjq47jw	2026-07-14 13:01:58.659	2026-07-14 13:01:58.659	cmrkb3cy40000y9h6lftwhcie
cmrknuo0a01d54hleqkc0eoqg	SM-T500	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:58.666	2026-07-14 13:01:58.666	cmrkb3cyo0001y9h6bozaifdg
cmrknuo0h01d74hlelziz2qc9	XT2143-1	cmrknujz5000r4hleshjq47jw	2026-07-14 13:01:58.674	2026-07-14 13:01:58.674	cmrkb3cy40000y9h6lftwhcie
cmrknuo0o01d94hle746i0af0	REALME 7 PRO	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:58.681	2026-07-14 13:01:58.681	cmrkb3cy40000y9h6lftwhcie
cmrknuo0t01db4hlejph3orh8	XT2091-3	cmrknujz5000r4hleshjq47jw	2026-07-14 13:01:58.685	2026-07-14 13:01:58.685	cmrkb3cy40000y9h6lftwhcie
cmrknuo0z01dd4hleg0f6nasn	REDMI NOTE 14 PRO	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:58.691	2026-07-14 13:01:58.691	cmrkb3cy40000y9h6lftwhcie
cmrknuo1401df4hle4y6fz7bn	XT2229-3	cmrknujz5000r4hleshjq47jw	2026-07-14 13:01:58.696	2026-07-14 13:01:58.696	cmrkb3cy40000y9h6lftwhcie
cmrknuo1801dh4hlef37r8gcp	IN2015	cmrknuk1a001d4hles4vy8kk2	2026-07-14 13:01:58.7	2026-07-14 13:01:58.7	cmrkb3cy40000y9h6lftwhcie
cmrknuo1c01dj4hlentb33bge	SM-J510F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:58.704	2026-07-14 13:01:58.704	cmrkb3cy40000y9h6lftwhcie
cmrknuo1h01dl4hlevygyowlo	SM-M115F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:58.709	2026-07-14 13:01:58.709	cmrkb3cy40000y9h6lftwhcie
cmrknuo1l01dn4hleeju5alrr	REDMI A2 PLUS	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:58.713	2026-07-14 13:01:58.713	cmrkb3cy40000y9h6lftwhcie
cmrknuo1o01dp4hle1lhhs8wc	MI 11 LITE NE 5G	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:58.716	2026-07-14 13:01:58.716	cmrkb3cy40000y9h6lftwhcie
cmrknuo1s01dr4hleshfvguwn	GM1911	cmrknuk1a001d4hles4vy8kk2	2026-07-14 13:01:58.72	2026-07-14 13:01:58.72	cmrkb3cy40000y9h6lftwhcie
cmrknuo1w01dt4hleivom2db4	WRTB-WFE9L	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:58.725	2026-07-14 13:01:58.725	cmrknujxm000b4hle4o2fwrvs
cmrknuo2001dv4hle7zqtxv68	PIXLE 1	cmrknuk0x00194hlevg4ydqsz	2026-07-14 13:01:58.729	2026-07-14 13:01:58.729	cmrkb3cy40000y9h6lftwhcie
cmrknuo2401dx4hle2lfbgsiq	MI 12T PRO	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:58.732	2026-07-14 13:01:58.732	cmrkb3cy40000y9h6lftwhcie
cmrknuo2701dz4hlewq1kem6m	A307FN	cmrknujzy000z4hlef0vui8me	2026-07-14 13:01:58.735	2026-07-14 13:01:58.735	cmrkb3cy40000y9h6lftwhcie
cmrknuo2c01e14hlejg8sv4pb	A307	cmrknujzy000z4hlef0vui8me	2026-07-14 13:01:58.74	2026-07-14 13:01:58.74	cmrkb3cy40000y9h6lftwhcie
cmrknuo2h01e34hlertc0x4s5	XT2221-1	cmrknujz5000r4hleshjq47jw	2026-07-14 13:01:58.745	2026-07-14 13:01:58.745	cmrkb3cy40000y9h6lftwhcie
cmrknuo2l01e54hleh9qmojde	V15IIL	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:01:58.75	2026-07-14 13:01:58.75	cmrknujxm000b4hle4o2fwrvs
cmrknuo2q01e74hleag7k36l7	X00LD	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:58.755	2026-07-14 13:01:58.755	cmrkb3cy40000y9h6lftwhcie
cmrknuo2w01e94hle9zl1nksr	LON-AL00	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:58.76	2026-07-14 13:01:58.76	cmrkb3cy40000y9h6lftwhcie
cmrknuo3101eb4hle8gbtg5j5	XIAOMI 11 LITE 5G NE	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:58.765	2026-07-14 13:01:58.765	cmrkb3cy40000y9h6lftwhcie
cmrknuo3601ed4hletqs6s0qn	K70 PRO 5G	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:58.77	2026-07-14 13:01:58.77	cmrkb3cy40000y9h6lftwhcie
cmrknuo3b01ef4hlei4ibwjo7	CLT-AL01	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:58.775	2026-07-14 13:01:58.775	cmrkb3cy40000y9h6lftwhcie
cmrknuo3g01eh4hleooea7rvy	SM-G900V	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:58.78	2026-07-14 13:01:58.78	cmrkb3cy40000y9h6lftwhcie
cmrknuo3k01ej4hlemo87zehh	INSPIRON 16 PLUS	cmrknujzd000t4hle1ujh33no	2026-07-14 13:01:58.785	2026-07-14 13:01:58.785	cmrknujxm000b4hle4o2fwrvs
cmrknuo3q01el4hlefa11yfjl	XE700T1C	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:58.79	2026-07-14 13:01:58.79	cmrknujxm000b4hle4o2fwrvs
cmrknuo3v01en4hle3qjrm9pl	C6833	cmrknujyl000l4hlezisknz7b	2026-07-14 13:01:58.795	2026-07-14 13:01:58.795	cmrkb3cy40000y9h6lftwhcie
cmrknuo4001ep4hle56fnsdf9	15P-390NR	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:01:58.8	2026-07-14 13:01:58.8	cmrknujxm000b4hle4o2fwrvs
cmrknuo4501er4hlekb9bmh71	WRTD-WDH9	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:58.806	2026-07-14 13:01:58.806	cmrknujxm000b4hle4o2fwrvs
cmrknuo4b01et4hlejhu8lhls	A1707	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:58.811	2026-07-14 13:01:58.811	cmrknujxm000b4hle4o2fwrvs
cmrknuo4f01ev4hlevicl5cja	IDEAPAD 3	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:01:58.815	2026-07-14 13:01:58.815	cmrknujxm000b4hle4o2fwrvs
cmrknuo4k01ex4hles4kgi66t	S10-231U	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:58.82	2026-07-14 13:01:58.82	cmrkb3cyo0001y9h6bozaifdg
cmrknuo4p01ez4hle2kp54a95	G60S	cmrknujz5000r4hleshjq47jw	2026-07-14 13:01:58.825	2026-07-14 13:01:58.825	cmrkb3cy40000y9h6lftwhcie
cmrknuo4t01f14hlerb2z9niv	13T	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:58.83	2026-07-14 13:01:58.83	cmrkb3cy40000y9h6lftwhcie
cmrknuo4x01f34hlezk7vgnba	IDEAPAD 520	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:01:58.833	2026-07-14 13:01:58.833	cmrknujxm000b4hle4o2fwrvs
cmrknuo5201f54hle99vugfc5	7D-501U	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:58.838	2026-07-14 13:01:58.838	cmrkb3cyo0001y9h6bozaifdg
cmrknuo5701f74hleupy9c886	ASPIRE ES1-332	cmrknuk0500114hleha2g5pf3	2026-07-14 13:01:58.843	2026-07-14 13:01:58.843	cmrknujxm000b4hle4o2fwrvs
cmrknuo5c01f94hlen9ug5nou	SM-G960F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:58.848	2026-07-14 13:01:58.848	cmrkb3cy40000y9h6lftwhcie
cmrknuo5h01fb4hlehtweoe72	A2890	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:58.853	2026-07-14 13:01:58.853	cmrkb3cy40000y9h6lftwhcie
cmrknuo5m01fd4hle9dnskf5s	M509B	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:58.858	2026-07-14 13:01:58.858	cmrknujxm000b4hle4o2fwrvs
cmrknuo5r01ff4hley5bajbni	POCO X6 PRO 5G	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:58.863	2026-07-14 13:01:58.863	cmrkb3cy40000y9h6lftwhcie
cmrknuo5v01fh4hle7suvs5wj	ta-1198	cmrknuk1s001i4hleqifj4gnr	2026-07-14 13:01:58.868	2026-07-14 13:01:58.868	cmrkb3cy40000y9h6lftwhcie
cmrknuo6001fj4hlefya1c3wf	NARZO 50	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:58.873	2026-07-14 13:01:58.873	cmrkb3cy40000y9h6lftwhcie
cmrknuo6501fl4hle908lt7lz	THINKPAD 10	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:01:58.878	2026-07-14 13:01:58.878	cmrknujxm000b4hle4o2fwrvs
cmrknuo6a01fn4hlerj7dp9aq	XT2153	cmrknujz5000r4hleshjq47jw	2026-07-14 13:01:58.882	2026-07-14 13:01:58.882	cmrkb3cy40000y9h6lftwhcie
cmrknuo6e01fp4hlelf44u0c9	X44H	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:58.887	2026-07-14 13:01:58.887	cmrknujxm000b4hle4o2fwrvs
cmrknuo6k01fr4hleqqhw2lfp	ZENBOOK14	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:58.893	2026-07-14 13:01:58.893	cmrknujxm000b4hle4o2fwrvs
cmrknuo6p01ft4hledx2on9mp	UX430U	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:58.897	2026-07-14 13:01:58.897	cmrknujxm000b4hle4o2fwrvs
cmrknuo6u01fv4hlebvymep2l	FX706H	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:58.902	2026-07-14 13:01:58.902	cmrkb3cy40000y9h6lftwhcie
cmrknuo7001fx4hlegaev23ys	N552V	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:58.908	2026-07-14 13:01:58.908	cmrkb3cy40000y9h6lftwhcie
cmrknuo7501fz4hlevmt0rm17	Z51	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:01:58.913	2026-07-14 13:01:58.913	cmrknujxm000b4hle4o2fwrvs
cmrknuo7a01g14hle3vr7g01t	UX360U	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:58.918	2026-07-14 13:01:58.918	cmrknujxm000b4hle4o2fwrvs
cmrknuo7f01g34hlekix4p3qi	IDEAPAD GAMING 3	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:01:58.923	2026-07-14 13:01:58.923	cmrknujxm000b4hle4o2fwrvs
cmrknuo7k01g54hleyba4r0x1	SM-A536B	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:58.929	2026-07-14 13:01:58.929	cmrkb3cy40000y9h6lftwhcie
cmrknuo7p01g74hle1tay622j	REDMI A3	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:58.933	2026-07-14 13:01:58.933	cmrkb3cy40000y9h6lftwhcie
cmrknuo7u01g94hlevlnasz7g	SM-G930U	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:58.938	2026-07-14 13:01:58.938	cmrkb3cy40000y9h6lftwhcie
cmrknuo7z01gb4hlezfjy8ywy	ELITE BOOK 840	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:01:58.944	2026-07-14 13:01:58.944	cmrknujxm000b4hle4o2fwrvs
cmrknuo8401gd4hleeoeclapi	SM-T285	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:58.948	2026-07-14 13:01:58.948	cmrkb3cyo0001y9h6bozaifdg
cmrknuo8901gf4hlel7a19k8l	PN07110	cmrknujzy000z4hlef0vui8me	2026-07-14 13:01:58.954	2026-07-14 13:01:58.954	cmrkb3cy40000y9h6lftwhcie
cmrknuo8g01gh4hle9fik34ph	A1674	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:58.96	2026-07-14 13:01:58.96	cmrkb3cyo0001y9h6bozaifdg
cmrknuo8k01gj4hlevwvgi1ty	S-091713	cmrknuk1f001f4hle4qdiojps	2026-07-14 13:01:58.965	2026-07-14 13:01:58.965	cmrkb3cy40000y9h6lftwhcie
cmrknuo8q01gl4hle4a4h38ih	MI MAX 2	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:58.97	2026-07-14 13:01:58.97	cmrkb3cy40000y9h6lftwhcie
cmrknuo8w01gn4hle1hxkq8kq	IDEAPAD 500	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:01:58.976	2026-07-14 13:01:58.976	cmrknujxm000b4hle4o2fwrvs
cmrknuo9101gp4hle5v0210dm	NARZO A50	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:58.981	2026-07-14 13:01:58.981	cmrkb3cy40000y9h6lftwhcie
cmrknuo9601gr4hledgp8ba6c	SM-A9100	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:58.986	2026-07-14 13:01:58.986	cmrkb3cy40000y9h6lftwhcie
cmrknuo9c01gt4hlee4virg97	F9	cmrknuk1c001e4hleq9bl3u7w	2026-07-14 13:01:58.992	2026-07-14 13:01:58.992	cmrkb3cy40000y9h6lftwhcie
cmrknuo9h01gv4hlexo1t13ns	REDMI NOTE 13 PRO 5G	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:58.997	2026-07-14 13:01:58.997	cmrkb3cy40000y9h6lftwhcie
cmrknuo9m01gx4hleoieg5lng	A1533	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:59.002	2026-07-14 13:01:59.002	cmrkb3cy40000y9h6lftwhcie
cmrknuo9s01gz4hleu7gkgzce	LATITUDE E5520	cmrknujzd000t4hle1ujh33no	2026-07-14 13:01:59.008	2026-07-14 13:01:59.008	cmrknujxm000b4hle4o2fwrvs
cmrknuo9x01h14hleb98ysrw4	THINKPAD 15 G2 ITL	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:01:59.013	2026-07-14 13:01:59.013	cmrknujxm000b4hle4o2fwrvs
cmrknuoa101h34hlei7ex1o0y	BAND	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:59.018	2026-07-14 13:01:59.018	cmrknujwz00044hle5lxikvcu
cmrknuoa701h54hle3s6sl2n3	IDEAPAD MIIX 510-12ISK	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:01:59.023	2026-07-14 13:01:59.023	cmrknujxm000b4hle4o2fwrvs
cmrknuoac01h74hlesbl0wt3n	IDEAPAD Z470	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:01:59.028	2026-07-14 13:01:59.028	cmrknujxm000b4hle4o2fwrvs
cmrknuoah01h94hlemz28ry7f	A1990	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:59.033	2026-07-14 13:01:59.033	cmrknujxm000b4hle4o2fwrvs
cmrknuoam01hb4hlej1tbgedg	XT2203	cmrknujz5000r4hleshjq47jw	2026-07-14 13:01:59.038	2026-07-14 13:01:59.038	cmrkb3cy40000y9h6lftwhcie
cmrknuoaq01hd4hlegzoieaxt	E50-70	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:01:59.043	2026-07-14 13:01:59.043	cmrknujxm000b4hle4o2fwrvs
cmrknuoaw01hf4hledzslt65v	E50	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:01:59.048	2026-07-14 13:01:59.048	cmrknujxm000b4hle4o2fwrvs
cmrknuob001hh4hlefvd51qyi	14-CF1061ST	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:01:59.053	2026-07-14 13:01:59.053	cmrknujxm000b4hle4o2fwrvs
cmrknuob501hj4hleaveyxgz8	TL688	cmrknuk1f001f4hle4qdiojps	2026-07-14 13:01:59.058	2026-07-14 13:01:59.058	cmrkb3cy40000y9h6lftwhcie
cmrknuoba01hl4hleob6f6et9	A1530	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:59.062	2026-07-14 13:01:59.062	cmrkb3cy40000y9h6lftwhcie
cmrknuobf01hn4hlep85sg0es	PIXLE 5	cmrknuk0x00194hlevg4ydqsz	2026-07-14 13:01:59.068	2026-07-14 13:01:59.068	cmrkb3cy40000y9h6lftwhcie
cmrknuobk01hp4hleqshumwc2	S904	cmrknujys000n4hlezjygamno	2026-07-14 13:01:59.072	2026-07-14 13:01:59.072	cmrknujxm000b4hle4o2fwrvs
cmrknuobp01hr4hlebkw92v4e	SM-R365	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:59.077	2026-07-14 13:01:59.077	cmrknujwz00044hle5lxikvcu
cmrknuobt01ht4hle6epe7l8g	A1633	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:59.081	2026-07-14 13:01:59.081	cmrkb3cy40000y9h6lftwhcie
cmrknuobx01hv4hlefz804jdi	A2218	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:59.086	2026-07-14 13:01:59.086	cmrkb3cy40000y9h6lftwhcie
cmrknuoc301hx4hlekf44ze8h	LLD-L21	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:59.091	2026-07-14 13:01:59.091	cmrkb3cy40000y9h6lftwhcie
cmrknuoc801hz4hle96ye9vxs	R510Z	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:59.096	2026-07-14 13:01:59.096	cmrknujxm000b4hle4o2fwrvs
cmrknuocd01i14hleqd0rgtvs	REALME C55	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:59.101	2026-07-14 13:01:59.101	cmrkb3cy40000y9h6lftwhcie
cmrknuoci01i34hlejk706epq	A1893	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:59.106	2026-07-14 13:01:59.106	cmrkb3cyo0001y9h6bozaifdg
cmrknuocn01i54hlez45d3ncj	LEO-BX9	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:59.111	2026-07-14 13:01:59.111	cmrknujwz00044hle5lxikvcu
cmrknuocr01i74hlep2dk26bs	SM-P205	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:59.115	2026-07-14 13:01:59.115	cmrkb3cyo0001y9h6bozaifdg
cmrknuocw01i94hlei5vugbjn	IDEAPAD L3	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:01:59.121	2026-07-14 13:01:59.121	cmrknujxm000b4hle4o2fwrvs
cmrknuod201ib4hlej5cbpofh	SM-M146B	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:59.126	2026-07-14 13:01:59.126	cmrkb3cy40000y9h6lftwhcie
cmrknuod601id4hle1nfrrl0r	SM-A536E	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:59.13	2026-07-14 13:01:59.13	cmrkb3cy40000y9h6lftwhcie
cmrknuodb01if4hlexseosb6e	A2337	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:59.135	2026-07-14 13:01:59.135	cmrknujxm000b4hle4o2fwrvs
cmrknuodf01ih4hleynn6oty1	S 1	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:59.14	2026-07-14 13:01:59.14	cmrkb3cy40000y9h6lftwhcie
cmrknuodk01ij4hle21d6lt3n	R427F	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:59.144	2026-07-14 13:01:59.144	cmrknujxm000b4hle4o2fwrvs
cmrknuodp01il4hleaw7kwffh	G6-U10	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:59.149	2026-07-14 13:01:59.149	cmrkb3cy40000y9h6lftwhcie
cmrknuodu01in4hlex554c8fk	X543U	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:59.154	2026-07-14 13:01:59.154	cmrknujxm000b4hle4o2fwrvs
cmrknuodz01ip4hlestngk357	MI 6X	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:59.159	2026-07-14 13:01:59.159	cmrkb3cy40000y9h6lftwhcie
cmrknuoe301ir4hledym9gwe1	JDN2-L09	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:59.163	2026-07-14 13:01:59.163	cmrkb3cyo0001y9h6bozaifdg
cmrknuoe701it4hleku6wiunt	SM-G780F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:59.167	2026-07-14 13:01:59.167	cmrkb3cy40000y9h6lftwhcie
cmrknuoea01iv4hles9453ari	ZBOOK 15U G5	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:01:59.171	2026-07-14 13:01:59.171	cmrknujxm000b4hle4o2fwrvs
cmrknuoee01ix4hlerugo72qn	SM-I8190	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:59.175	2026-07-14 13:01:59.175	cmrkb3cy40000y9h6lftwhcie
cmrknuoeh01iz4hle5yo6dk12	SM-R890	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:59.178	2026-07-14 13:01:59.178	cmrknujwz00044hle5lxikvcu
cmrknuoek01j14hlefvcu8hvk	TA-1043	cmrknuk1s001i4hleqifj4gnr	2026-07-14 13:01:59.181	2026-07-14 13:01:59.181	cmrkb3cy40000y9h6lftwhcie
cmrknuoen01j34hlefdj8ynuv	REDMI K40 GAMING	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:59.184	2026-07-14 13:01:59.184	cmrkb3cy40000y9h6lftwhcie
cmrknuoeq01j54hleo73j9gkt	Z50-70	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:01:59.187	2026-07-14 13:01:59.187	cmrknujxm000b4hle4o2fwrvs
cmrknuoeu01j74hlebqtb4tst	HRY-LX1T	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:59.19	2026-07-14 13:01:59.19	cmrkb3cy40000y9h6lftwhcie
cmrknuoew01j94hleygdwwwc8	REDMI 6 PRO	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:59.193	2026-07-14 13:01:59.193	cmrkb3cy40000y9h6lftwhcie
cmrknuoez01jb4hle5bfkzebe	GT 2	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:59.196	2026-07-14 13:01:59.196	cmrknujwz00044hle5lxikvcu
cmrknuof201jd4hlee7goxjx5	PAVILION X360	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:01:59.198	2026-07-14 13:01:59.198	cmrknujxm000b4hle4o2fwrvs
cmrknuof401jf4hlep3kp709x	M910N	cmrknujzy000z4hlef0vui8me	2026-07-14 13:01:59.2	2026-07-14 13:01:59.2	cmrkb3cy40000y9h6lftwhcie
cmrknuof601jh4hleny589qps	POCO C3	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:59.203	2026-07-14 13:01:59.203	cmrkb3cy40000y9h6lftwhcie
cmrknuof901jj4hleupst0j14	RENO Z2	cmrknuk1c001e4hleq9bl3u7w	2026-07-14 13:01:59.205	2026-07-14 13:01:59.205	cmrkb3cy40000y9h6lftwhcie
cmrknuofb01jl4hlei81d3hef	PRECISION M4700	cmrknujzd000t4hle1ujh33no	2026-07-14 13:01:59.207	2026-07-14 13:01:59.207	cmrknujxm000b4hle4o2fwrvs
cmrknuofd01jn4hle7si6rm1y	SM-T580	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:59.209	2026-07-14 13:01:59.209	cmrkb3cyo0001y9h6bozaifdg
cmrknuoff01jp4hlequm7ludo	N551V	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:59.211	2026-07-14 13:01:59.211	cmrknujxm000b4hle4o2fwrvs
cmrknuofh01jr4hleml093wgz	L55M5-5ASP	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:59.213	2026-07-14 13:01:59.213	cmrknujy0000g4hleg9xefyth
cmrknuofi01jt4hle8q2e1aq3	AGR-L09	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:59.215	2026-07-14 13:01:59.215	cmrkb3cyo0001y9h6bozaifdg
cmrknuofk01jv4hle3r0h1o64	RENO7 Z 5G	cmrknuk1c001e4hleq9bl3u7w	2026-07-14 13:01:59.216	2026-07-14 13:01:59.216	cmrkb3cy40000y9h6lftwhcie
cmrknuofm01jx4hlefaimjqo9	REALME 7 5G	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:59.218	2026-07-14 13:01:59.218	cmrkb3cy40000y9h6lftwhcie
cmrknuofo01jz4hled63cpv1p	X21S	cmrknujzl000v4hle1n0o4b2k	2026-07-14 13:01:59.22	2026-07-14 13:01:59.22	cmrkb3cy40000y9h6lftwhcie
cmrknuofq01k14hle179efm2t	NOTE 6	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:59.222	2026-07-14 13:01:59.222	cmrkb3cy40000y9h6lftwhcie
cmrknuofs01k34hlea3v9k65c	L55M7-Q2ME	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:59.224	2026-07-14 13:01:59.224	cmrknujy0000g4hleg9xefyth
cmrknuofu01k54hleo02eav8k	A2759	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:59.226	2026-07-14 13:01:59.226	cmrkb3cyo0001y9h6bozaifdg
cmrknuofw01k74hle9lmikh1e	SM-T530	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:59.228	2026-07-14 13:01:59.228	cmrkb3cyo0001y9h6bozaifdg
cmrknuofy01k94hle5bq9n4ps	XT2016-1	cmrknujz5000r4hleshjq47jw	2026-07-14 13:01:59.23	2026-07-14 13:01:59.23	cmrkb3cy40000y9h6lftwhcie
cmrknuog001kb4hle3xbh9az9	MI 12 PRO	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:59.232	2026-07-14 13:01:59.232	cmrkb3cy40000y9h6lftwhcie
cmrknuog201kd4hlejk1mlvbo	SM-A037F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:59.234	2026-07-14 13:01:59.234	cmrkb3cy40000y9h6lftwhcie
cmrknuog401kf4hlehs7hmdqe	SNE-LX1	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:59.236	2026-07-14 13:01:59.236	cmrkb3cy40000y9h6lftwhcie
cmrknuog601kh4hle9z9mdj8e	SM-A346E	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:59.238	2026-07-14 13:01:59.238	cmrkb3cy40000y9h6lftwhcie
cmrknuog801kj4hle72940ie4	Y33 S	cmrknujzl000v4hle1n0o4b2k	2026-07-14 13:01:59.24	2026-07-14 13:01:59.24	cmrkb3cy40000y9h6lftwhcie
cmrknuoga01kl4hles9o5e99b	A1708	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:59.242	2026-07-14 13:01:59.242	cmrknujxm000b4hle4o2fwrvs
cmrknuogc01kn4hlefu8xvbr2	TB3-730X	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:01:59.244	2026-07-14 13:01:59.244	cmrkb3cyo0001y9h6bozaifdg
cmrknuogd01kp4hleohz3t2pk	PIXEL 6	cmrknuk0x00194hlevg4ydqsz	2026-07-14 13:01:59.246	2026-07-14 13:01:59.246	cmrkb3cy40000y9h6lftwhcie
cmrknuogf01kr4hlezdclbd0t	TA-1365	cmrknuk1s001i4hleqifj4gnr	2026-07-14 13:01:59.248	2026-07-14 13:01:59.248	cmrkb3cy40000y9h6lftwhcie
cmrknuogh01kt4hle9h878o64	TA-1201	cmrknuk1s001i4hleqifj4gnr	2026-07-14 13:01:59.25	2026-07-14 13:01:59.25	cmrkb3cy40000y9h6lftwhcie
cmrknuogk01kv4hle0npj2ycb	SM-G7818	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:59.252	2026-07-14 13:01:59.252	cmrkb3cy40000y9h6lftwhcie
cmrknuogn01kx4hlehthcv6vk	SM-M215	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:59.256	2026-07-14 13:01:59.256	cmrkb3cy40000y9h6lftwhcie
cmrknuogq01kz4hleiikj69vs	TA-1325	cmrknuk1s001i4hleqifj4gnr	2026-07-14 13:01:59.258	2026-07-14 13:01:59.258	cmrkb3cy40000y9h6lftwhcie
cmrknuogt01l14hlef0diwx5w	HTC Jetstream	cmrknujzy000z4hlef0vui8me	2026-07-14 13:01:59.261	2026-07-14 13:01:59.261	cmrkb3cyo0001y9h6bozaifdg
cmrknuogv01l34hlefeegmjq6	POCO C65	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:59.263	2026-07-14 13:01:59.263	cmrkb3cy40000y9h6lftwhcie
cmrknuogx01l54hle7ocgpls4	AUM-L29	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:59.265	2026-07-14 13:01:59.265	cmrkb3cy40000y9h6lftwhcie
cmrknuoh001l74hle2oiqf1zu	Y70-70	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:01:59.268	2026-07-14 13:01:59.268	cmrknujxm000b4hle4o2fwrvs
cmrknuoh301l94hlep4v7448i	YOGA 3 PRO	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:01:59.272	2026-07-14 13:01:59.272	cmrknujxm000b4hle4o2fwrvs
cmrknuoh601lb4hleq8nhyem7	DRA-LX9	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:59.275	2026-07-14 13:01:59.275	cmrkb3cy40000y9h6lftwhcie
cmrknuoh801ld4hlebivzzopl	POCO X6 PRO	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:59.277	2026-07-14 13:01:59.277	cmrkb3cy40000y9h6lftwhcie
cmrknuoha01lf4hlecr70yo4m	MI 8 PRO	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:59.279	2026-07-14 13:01:59.279	cmrkb3cy40000y9h6lftwhcie
cmrknuohc01lh4hleoc71o13z	SVF14C1WW	cmrknujyl000l4hlezisknz7b	2026-07-14 13:01:59.281	2026-07-14 13:01:59.281	cmrknujxm000b4hle4o2fwrvs
cmrknuohe01lj4hle4fqzmi90	REALME C53	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:59.282	2026-07-14 13:01:59.282	cmrkb3cy40000y9h6lftwhcie
cmrknuohh01ll4hlejjoreky9	NP300E5V	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:59.285	2026-07-14 13:01:59.285	cmrknujxm000b4hle4o2fwrvs
cmrknuohk01ln4hlexx38hirk	MOA-LX9N	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:59.288	2026-07-14 13:01:59.288	cmrkb3cy40000y9h6lftwhcie
cmrknuohn01lp4hlesobcw6k0	Redmi K50 Gaming	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:59.291	2026-07-14 13:01:59.291	cmrkb3cy40000y9h6lftwhcie
cmrknuoho01lr4hleaurm44nh	XT2255-1	cmrknujz5000r4hleshjq47jw	2026-07-14 13:01:59.293	2026-07-14 13:01:59.293	cmrkb3cy40000y9h6lftwhcie
cmrknuohq01lt4hleqqgjgr0a	A2602	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:59.295	2026-07-14 13:01:59.295	cmrkb3cyo0001y9h6bozaifdg
cmrknuohs01lv4hleican7c4u	REDMI 10 PRIME	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:59.297	2026-07-14 13:01:59.297	cmrkb3cy40000y9h6lftwhcie
cmrknuohu01lx4hle39kn8ay9	REDMI 10A	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:59.298	2026-07-14 13:01:59.298	cmrkb3cy40000y9h6lftwhcie
cmrknuohw01lz4hle30xsk0oo	xmwtcl02	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:59.3	2026-07-14 13:01:59.3	cmrknujwz00044hle5lxikvcu
cmrknuohz01m14hleh7mr4wck	S2	cmrknuk0s00184hlelqgqvib3	2026-07-14 13:01:59.304	2026-07-14 13:01:59.304	cmrknujws00024hle61bdckim
cmrknuoi201m34hlecd7mc1uo	SVE14AA11W	cmrknujyl000l4hlezisknz7b	2026-07-14 13:01:59.307	2026-07-14 13:01:59.307	cmrknujxm000b4hle4o2fwrvs
cmrknuoi501m54hletfx3yo9p	SVE151E11L	cmrknujyl000l4hlezisknz7b	2026-07-14 13:01:59.309	2026-07-14 13:01:59.309	cmrknujxm000b4hle4o2fwrvs
cmrknuoi701m74hlepkv62zhr	NOTHING PHONE 1	cmrknuk0e00144hlema8gy8pv	2026-07-14 13:01:59.311	2026-07-14 13:01:59.311	cmrkb3cy40000y9h6lftwhcie
cmrknuoi801m94hlej0lthnh5	A2105	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:59.313	2026-07-14 13:01:59.313	cmrkb3cy40000y9h6lftwhcie
cmrknuoia01mb4hleol6fvvef	S8-701U	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:59.315	2026-07-14 13:01:59.315	cmrkb3cyo0001y9h6bozaifdg
cmrknuoic01md4hlehi28paqi	V310	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:01:59.316	2026-07-14 13:01:59.316	cmrknujxm000b4hle4o2fwrvs
cmrknuoie01mf4hleakdvxbgv	RENO8 PRO	cmrknuk1c001e4hleq9bl3u7w	2026-07-14 13:01:59.318	2026-07-14 13:01:59.318	cmrkb3cy40000y9h6lftwhcie
cmrknuoih01mh4hle6u165e9v	XPAW013	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:59.321	2026-07-14 13:01:59.321	cmrknujwz00044hle5lxikvcu
cmrknuoij01mj4hle0yo8ufdy	SM-T819	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:59.324	2026-07-14 13:01:59.324	cmrkb3cyo0001y9h6bozaifdg
cmrknuoim01ml4hlepaj1s7i0	AGS3K-L09	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:59.326	2026-07-14 13:01:59.326	cmrkb3cyo0001y9h6bozaifdg
cmrknuoio01mn4hlefcquve2l	X00TD	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:59.328	2026-07-14 13:01:59.328	cmrkb3cy40000y9h6lftwhcie
cmrknuoip01mp4hle4i7rw5fr	MOTO G84 5G	cmrknujz5000r4hleshjq47jw	2026-07-14 13:01:59.33	2026-07-14 13:01:59.33	cmrkb3cy40000y9h6lftwhcie
cmrknuoir01mr4hle1lfugv1w	SM-A205F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:59.332	2026-07-14 13:01:59.332	cmrkb3cy40000y9h6lftwhcie
cmrknuoit01mt4hlelz7wqnx9	REDMI WATCH 4	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:59.334	2026-07-14 13:01:59.334	cmrknujwz00044hle5lxikvcu
cmrknuoiw01mv4hlezq0bcqwy	GM1901	cmrknuk1a001d4hles4vy8kk2	2026-07-14 13:01:59.337	2026-07-14 13:01:59.337	cmrkb3cy40000y9h6lftwhcie
cmrknuoiz01mx4hle57e2pbfm	SM-T595	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:59.34	2026-07-14 13:01:59.34	cmrkb3cyo0001y9h6bozaifdg
cmrknuoj201mz4hleq0fs09jo	E6533	cmrknujyl000l4hlezisknz7b	2026-07-14 13:01:59.342	2026-07-14 13:01:59.342	cmrkb3cy40000y9h6lftwhcie
cmrknuoj401n14hlem2hhjb71	BOH-WAQ9R	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:59.344	2026-07-14 13:01:59.344	cmrknujxm000b4hle4o2fwrvs
cmrknuoj601n34hlemvf2v8p0	V3-574G	cmrknuk0500114hleha2g5pf3	2026-07-14 13:01:59.346	2026-07-14 13:01:59.346	cmrknujxm000b4hle4o2fwrvs
cmrknuoj801n54hle7clnsp84	POCO F5 PRO 5G	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:59.348	2026-07-14 13:01:59.348	cmrkb3cy40000y9h6lftwhcie
cmrknuoja01n74hle7ayftw5y	BE2013	cmrknuk1a001d4hles4vy8kk2	2026-07-14 13:01:59.35	2026-07-14 13:01:59.35	cmrkb3cy40000y9h6lftwhcie
cmrknuojd01n94hlehcmzp2hf	K3502	cmrknuk0p00174hleoejfscfb	2026-07-14 13:01:59.354	2026-07-14 13:01:59.354	cmrkb3cy40000y9h6lftwhcie
cmrknuojg01nb4hletq85avi4	NITRO 5	cmrknuk0500114hleha2g5pf3	2026-07-14 13:01:59.356	2026-07-14 13:01:59.356	cmrknujxm000b4hle4o2fwrvs
cmrknuoji01nd4hlepmwsh17j	REDMI NORE 12 PRO PLUS 5G	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:59.359	2026-07-14 13:01:59.359	cmrkb3cy40000y9h6lftwhcie
cmrknuojl01nf4hle82ed53lz	SM-A300H	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:59.361	2026-07-14 13:01:59.361	cmrkb3cy40000y9h6lftwhcie
cmrknuojn01nh4hlesy59b57l	NTN-L22	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:59.363	2026-07-14 13:01:59.363	cmrkb3cy40000y9h6lftwhcie
cmrknuojp01nj4hle86a9gfhl	SM-T815	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:59.365	2026-07-14 13:01:59.365	cmrkb3cyo0001y9h6bozaifdg
cmrknuojr01nl4hlek45sbovj	REDMI PRO	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:59.367	2026-07-14 13:01:59.367	cmrkb3cy40000y9h6lftwhcie
cmrknuoju01nn4hlezvq1ig9z	COR-L29	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:59.37	2026-07-14 13:01:59.37	cmrkb3cy40000y9h6lftwhcie
cmrknuojx01np4hlexzvfz03p	X00PD	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:59.374	2026-07-14 13:01:59.374	cmrkb3cy40000y9h6lftwhcie
cmrknuojz01nr4hlevtxqs37i	XT2333-5	cmrknujz5000r4hleshjq47jw	2026-07-14 13:01:59.376	2026-07-14 13:01:59.376	cmrkb3cy40000y9h6lftwhcie
cmrknuok201nt4hle0vytcrys	TB-7305X	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:01:59.378	2026-07-14 13:01:59.378	cmrkb3cyo0001y9h6bozaifdg
cmrknuok301nv4hler67m279f	V570C	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:01:59.38	2026-07-14 13:01:59.38	cmrknujxm000b4hle4o2fwrvs
cmrknuok501nx4hlexb7oakfk	MS-16Y1	cmrknujz9000s4hleu8mshqu7	2026-07-14 13:01:59.382	2026-07-14 13:01:59.382	cmrknujxm000b4hle4o2fwrvs
cmrknuok801nz4hlebchr8zz4	PRA-LA1	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:59.384	2026-07-14 13:01:59.384	cmrkb3cy40000y9h6lftwhcie
cmrknuokb01o14hle8rw38s9v	SAMN-LX9	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:59.387	2026-07-14 13:01:59.387	cmrkb3cy40000y9h6lftwhcie
cmrknuoke01o34hlelk0uuawz	SM-G928C	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:59.39	2026-07-14 13:01:59.39	cmrkb3cy40000y9h6lftwhcie
cmrknuokg01o54hlezbko3a0c	SM-F731B	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:59.392	2026-07-14 13:01:59.392	cmrkb3cy40000y9h6lftwhcie
cmrknuoki01o74hleclc9ayru	MGA-LX9	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:59.395	2026-07-14 13:01:59.395	cmrkb3cy40000y9h6lftwhcie
cmrknuokk01o94hlerx3jagi6	SM-M317F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:59.397	2026-07-14 13:01:59.397	cmrkb3cy40000y9h6lftwhcie
cmrknuokm01ob4hlej8riwbqh	PRESARIO V5000	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:01:59.399	2026-07-14 13:01:59.399	cmrknujxm000b4hle4o2fwrvs
cmrknuoko01od4hlegnwnbhjm	0PE6500	cmrknujzy000z4hlef0vui8me	2026-07-14 13:01:59.401	2026-07-14 13:01:59.401	cmrkb3cy40000y9h6lftwhcie
cmrknuoks01of4hlepre750lv	ZBOOK 17 G3	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:01:59.404	2026-07-14 13:01:59.404	cmrknujxm000b4hle4o2fwrvs
cmrknuokv01oh4hlevtgdf95n	SVS13AA11L	cmrknujyl000l4hlezisknz7b	2026-07-14 13:01:59.407	2026-07-14 13:01:59.407	cmrknujxm000b4hle4o2fwrvs
cmrknuokx01oj4hle9pghfdgb	BAH3-L09	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:59.409	2026-07-14 13:01:59.409	cmrkb3cyo0001y9h6bozaifdg
cmrknuokz01ol4hlefz6aezal	RM-1035	cmrknuk1s001i4hleqifj4gnr	2026-07-14 13:01:59.411	2026-07-14 13:01:59.411	cmrkb3cy40000y9h6lftwhcie
cmrknuol101on4hletdi01ebh	Asus Fonepad 7 FE170CG	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:59.413	2026-07-14 13:01:59.413	cmrkb3cy40000y9h6lftwhcie
cmrknuol201op4hlevevlnb1x	8505X	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:59.415	2026-07-14 13:01:59.415	cmrkb3cyo0001y9h6bozaifdg
cmrknuol501or4hle88lok2ls	A5010	cmrknuk1a001d4hles4vy8kk2	2026-07-14 13:01:59.417	2026-07-14 13:01:59.417	cmrkb3cy40000y9h6lftwhcie
cmrknuol801ot4hlebtiox2j8	A2018	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:59.421	2026-07-14 13:01:59.421	cmrknujwz00044hle5lxikvcu
cmrknuolb01ov4hle5wj5a80r	SM-M205F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:59.423	2026-07-14 13:01:59.423	cmrkb3cy40000y9h6lftwhcie
cmrknuolg01ox4hle9f72q4vo	POCO M6 PRO	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:59.429	2026-07-14 13:01:59.429	cmrkb3cy40000y9h6lftwhcie
cmrknuolo01oz4hlenxyan6wm	XT2203-1	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:59.436	2026-07-14 13:01:59.436	cmrkb3cy40000y9h6lftwhcie
cmrknuolr01p14hle9vbdxjm5	SM-P619	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:59.44	2026-07-14 13:01:59.44	cmrkb3cyo0001y9h6bozaifdg
cmrknuolv01p34hlem1uttaoy	SM-P625	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:59.443	2026-07-14 13:01:59.443	cmrkb3cyo0001y9h6bozaifdg
cmrknuoly01p54hleaas6mgr0	SM-T225	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:59.446	2026-07-14 13:01:59.446	cmrkb3cyo0001y9h6bozaifdg
cmrknuom001p74hlegbrxcdmq	A1954	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:59.449	2026-07-14 13:01:59.449	cmrkb3cyo0001y9h6bozaifdg
cmrknuom201p94hleygxaf4gf	TA-1359	cmrknuk1s001i4hleqifj4gnr	2026-07-14 13:01:59.451	2026-07-14 13:01:59.451	cmrkb3cy40000y9h6lftwhcie
cmrknuom601pb4hleugnfxgu2	G2	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:59.455	2026-07-14 13:01:59.455	cmrknujwz00044hle5lxikvcu
cmrknuoma01pd4hleem8f6a9i	A2633	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:59.458	2026-07-14 13:01:59.458	cmrkb3cy40000y9h6lftwhcie
cmrknuomc01pf4hlenj15qxj1	BOB-WAI9Q	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:59.461	2026-07-14 13:01:59.461	cmrknujxm000b4hle4o2fwrvs
cmrknuome01ph4hlepy6pns1m	REDMI 12	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:59.463	2026-07-14 13:01:59.463	cmrkb3cy40000y9h6lftwhcie
cmrknuomg01pj4hleesr2h1tq	A1428	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:59.464	2026-07-14 13:01:59.464	cmrkb3cy40000y9h6lftwhcie
cmrknuomi01pl4hle2kkt4ifo	IDEAPAD Y700-17ISK	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:01:59.466	2026-07-14 13:01:59.466	cmrknujxm000b4hle4o2fwrvs
cmrknuoml01pn4hlezaszhyys	A1634	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:59.47	2026-07-14 13:01:59.47	cmrkb3cy40000y9h6lftwhcie
cmrknuomp01pp4hlejz35b6bx	PROBOOK 440 G9	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:01:59.473	2026-07-14 13:01:59.473	cmrknujxm000b4hle4o2fwrvs
cmrknuomr01pr4hlet0pu2hr5	GT2 PRO	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:59.475	2026-07-14 13:01:59.475	cmrknujwz00044hle5lxikvcu
cmrknuomt01pt4hle9r82d45q	SM-R500	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:59.478	2026-07-14 13:01:59.478	cmrknujwz00044hle5lxikvcu
cmrknuomv01pv4hleaabqo83p	UX360C	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:59.479	2026-07-14 13:01:59.479	cmrknujxm000b4hle4o2fwrvs
cmrknuomx01px4hlea6hqgctw	REDMI NOTE 13 PRO PLUS	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:59.481	2026-07-14 13:01:59.481	cmrkb3cy40000y9h6lftwhcie
cmrknuomz01pz4hlegs8tgxc2	REDMI 13C	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:59.483	2026-07-14 13:01:59.483	cmrkb3cy40000y9h6lftwhcie
cmrknuon101q14hle5d5242k7	13C	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:59.486	2026-07-14 13:01:59.486	cmrkb3cy40000y9h6lftwhcie
cmrknuon501q34hle5k55v3n9	SM-A155F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:59.489	2026-07-14 13:01:59.489	cmrkb3cy40000y9h6lftwhcie
cmrknuon701q54hlep8stxxhb	VOSTRO-1510	cmrknujzd000t4hle1ujh33no	2026-07-14 13:01:59.492	2026-07-14 13:01:59.492	cmrknujxm000b4hle4o2fwrvs
cmrknuona01q74hlejuaead1d	SM-R590	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:59.494	2026-07-14 13:01:59.494	cmrknujwz00044hle5lxikvcu
cmrknuonc01q94hleucnwh963	REDMI 4A	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:59.497	2026-07-14 13:01:59.497	cmrkb3cy40000y9h6lftwhcie
cmrknuonf01qb4hlemgwxmr16	TB-8504X	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:59.499	2026-07-14 13:01:59.499	cmrkb3cyo0001y9h6bozaifdg
cmrknuoni01qd4hlec45sozvk	A1687	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:59.503	2026-07-14 13:01:59.503	cmrkb3cy40000y9h6lftwhcie
cmrknuonm01qf4hle5k00irhd	JPT-B19	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:59.506	2026-07-14 13:01:59.506	cmrknujwz00044hle5lxikvcu
cmrknuono01qh4hle656wrkf1	MOTO G9 PLAY	cmrknujz5000r4hleshjq47jw	2026-07-14 13:01:59.509	2026-07-14 13:01:59.509	cmrkb3cy40000y9h6lftwhcie
cmrknuonr01qj4hleorfr6tar	WAX-LX1	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:59.511	2026-07-14 13:01:59.511	cmrkb3cy40000y9h6lftwhcie
cmrknuont01ql4hleqzz6w1ed	GALAXY WATCH 2	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:59.513	2026-07-14 13:01:59.513	cmrknujwz00044hle5lxikvcu
cmrknuonv01qn4hlew3p7exwk	X55C	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:59.516	2026-07-14 13:01:59.516	cmrknujxm000b4hle4o2fwrvs
cmrknuonx01qp4hlezieomuv6	SM-A346B	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:59.518	2026-07-14 13:01:59.518	cmrkb3cy40000y9h6lftwhcie
cmrknuoo201qr4hlebmy4lv7q	SM-T805	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:59.522	2026-07-14 13:01:59.522	cmrkb3cyo0001y9h6bozaifdg
cmrknuoo501qt4hle9j4to3lw	INSPIRON 15	cmrknujzd000t4hle1ujh33no	2026-07-14 13:01:59.525	2026-07-14 13:01:59.525	cmrknujxm000b4hle4o2fwrvs
cmrknuoo701qv4hledxcuy8l5	15T-G400	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:01:59.527	2026-07-14 13:01:59.527	cmrknujxm000b4hle4o2fwrvs
cmrknuoo901qx4hlethda0jvz	Y15	cmrknujzl000v4hle1n0o4b2k	2026-07-14 13:01:59.529	2026-07-14 13:01:59.529	cmrkb3cy40000y9h6lftwhcie
cmrknuooa01qz4hleg8qv59gt	MI 12 LITE	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:59.531	2026-07-14 13:01:59.531	cmrkb3cy40000y9h6lftwhcie
cmrknuooc01r14hleggjqvib5	POCO X5 5G	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:59.533	2026-07-14 13:01:59.533	cmrkb3cy40000y9h6lftwhcie
cmrknuoof01r34hleocef0hw4	X5 5G	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:59.535	2026-07-14 13:01:59.535	cmrkb3cy40000y9h6lftwhcie
cmrknuooi01r54hlejw3nelvl	A2894	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:59.539	2026-07-14 13:01:59.539	cmrkb3cy40000y9h6lftwhcie
cmrknuool01r74hle77xz53b6	SM-A546E	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:59.541	2026-07-14 13:01:59.541	cmrkb3cy40000y9h6lftwhcie
cmrknuoon01r94hleze4tb37o	LAT-L29	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:59.543	2026-07-14 13:01:59.543	cmrkb3cy40000y9h6lftwhcie
cmrknuoop01rb4hleu0n8rnlm	SM-A710	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:59.546	2026-07-14 13:01:59.546	cmrkb3cy40000y9h6lftwhcie
cmrknuoor01rd4hlemviqsq3q	SVS131E21L	cmrknujyl000l4hlezisknz7b	2026-07-14 13:01:59.548	2026-07-14 13:01:59.548	cmrknujxm000b4hle4o2fwrvs
cmrknuoot01rf4hle95zdpz85	VIVOBOOK S15	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:59.55	2026-07-14 13:01:59.55	cmrknujxm000b4hle4o2fwrvs
cmrknuoox01rh4hleuyc8j4qu	D160	cmrknuk0p00174hleoejfscfb	2026-07-14 13:01:59.553	2026-07-14 13:01:59.553	cmrkb3cy40000y9h6lftwhcie
cmrknuop001rj4hle5q2do2z4	G8142	cmrknujyl000l4hlezisknz7b	2026-07-14 13:01:59.557	2026-07-14 13:01:59.557	cmrkb3cy40000y9h6lftwhcie
cmrknuop201rl4hleiy9z7byp	A1278	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:59.559	2026-07-14 13:01:59.559	cmrknujxm000b4hle4o2fwrvs
cmrknuop501rn4hlel9u8rm97	LEGION Y540	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:01:59.561	2026-07-14 13:01:59.561	cmrknujxm000b4hle4o2fwrvs
cmrknuop701rp4hle3wowew09	TA-1418	cmrknuk1s001i4hleqifj4gnr	2026-07-14 13:01:59.563	2026-07-14 13:01:59.563	cmrkb3cy40000y9h6lftwhcie
cmrknuop901rr4hlererwks1r	MDE5	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:59.565	2026-07-14 13:01:59.565	cmrkb3cy40000y9h6lftwhcie
cmrknuopc01rt4hle99jhr5ns	A1395	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:59.568	2026-07-14 13:01:59.568	cmrkb3cyo0001y9h6bozaifdg
cmrknuopg01rv4hlete8ydymk	NBB-WAE9P	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:59.572	2026-07-14 13:01:59.572	cmrknujxm000b4hle4o2fwrvs
cmrknuopj01rx4hle82qzodg9	TB-7304I	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:01:59.575	2026-07-14 13:01:59.575	cmrkb3cyo0001y9h6bozaifdg
cmrknuopl01rz4hletzbf7xtw	Alpha One	cmrknuk1f001f4hle4qdiojps	2026-07-14 13:01:59.577	2026-07-14 13:01:59.577	cmrkb3cy40000y9h6lftwhcie
cmrknuopn01s14hlewz249ue9	SM-P615	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:59.579	2026-07-14 13:01:59.579	cmrkb3cyo0001y9h6bozaifdg
cmrknuopp01s34hle27ln81zd	ASPIRE A715-71G	cmrknuk0500114hleha2g5pf3	2026-07-14 13:01:59.581	2026-07-14 13:01:59.581	cmrknujxm000b4hle4o2fwrvs
cmrknuops01s54hleoes33w3q	COMPAQ PRESARIO CQ40	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:01:59.584	2026-07-14 13:01:59.584	cmrknujxm000b4hle4o2fwrvs
cmrknuopw01s74hlesiytrujg	IDEAPAD 5	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:01:59.589	2026-07-14 13:01:59.589	cmrknujxm000b4hle4o2fwrvs
cmrknuoq001s94hleyl59xkq5	POCO M5s	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:59.592	2026-07-14 13:01:59.592	cmrkb3cy40000y9h6lftwhcie
cmrknuoq201sb4hlelb20835c	A1784	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:59.594	2026-07-14 13:01:59.594	cmrkb3cy40000y9h6lftwhcie
cmrknuoq401sd4hleamdfg2qi	NOTE 12 PRO  PLUS 5G	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:59.597	2026-07-14 13:01:59.597	cmrkb3cy40000y9h6lftwhcie
cmrknuoq701sf4hleuce7mpem	IDEAPAD Z510	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:01:59.599	2026-07-14 13:01:59.599	cmrknujxm000b4hle4o2fwrvs
cmrknuoq901sh4hle7y8e81p3	A2198	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:59.601	2026-07-14 13:01:59.601	cmrkb3cyo0001y9h6bozaifdg
cmrknuoqc01sj4hle7nuf8trt	N580V	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:59.604	2026-07-14 13:01:59.604	cmrknujxm000b4hle4o2fwrvs
cmrknuoqf01sl4hlem7uxtcm4	SM-J111F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:59.607	2026-07-14 13:01:59.607	cmrkb3cy40000y9h6lftwhcie
cmrknuoqh01sn4hleunb8ok4e	K016	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:59.609	2026-07-14 13:01:59.609	cmrkb3cyo0001y9h6bozaifdg
cmrknuoqj01sp4hleri5vcg0u	LUA-U22	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:59.611	2026-07-14 13:01:59.611	cmrkb3cy40000y9h6lftwhcie
cmrknuoql01sr4hle9cx959s8	SM-A025F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:59.613	2026-07-14 13:01:59.613	cmrkb3cy40000y9h6lftwhcie
cmrknuoqn01st4hleoxm8knog	REALME X2 PRO	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:59.615	2026-07-14 13:01:59.615	cmrkb3cy40000y9h6lftwhcie
cmrknuoqp01sv4hlen2la3vdr	JAD-AL50	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:59.618	2026-07-14 13:01:59.618	cmrkb3cy40000y9h6lftwhcie
cmrknuoqt01sx4hle2ojw2l29	A1901	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:59.622	2026-07-14 13:01:59.622	cmrkb3cy40000y9h6lftwhcie
cmrknuoqw01sz4hleq7cegxlg	VOSTRO 1310	cmrknujzd000t4hle1ujh33no	2026-07-14 13:01:59.625	2026-07-14 13:01:59.625	cmrknujxm000b4hle4o2fwrvs
cmrknuor001t14hle6pm0e1ec	C65	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:59.628	2026-07-14 13:01:59.628	cmrkb3cy40000y9h6lftwhcie
cmrknuor301t34hle4hzdthpu	A1430	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:59.631	2026-07-14 13:01:59.631	cmrkb3cyo0001y9h6bozaifdg
cmrknuor501t54hle8a0l610i	ELE-L29	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:59.634	2026-07-14 13:01:59.634	cmrkb3cy40000y9h6lftwhcie
cmrknuor801t74hlexm8yju19	BND-L21	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:59.636	2026-07-14 13:01:59.636	cmrkb3cy40000y9h6lftwhcie
cmrknuorb01t94hleekhy5p50	BND	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:59.64	2026-07-14 13:01:59.64	cmrkb3cy40000y9h6lftwhcie
cmrknuore01tb4hleyec5i72x	B181	cmrknuk0e00144hlema8gy8pv	2026-07-14 13:01:59.642	2026-07-14 13:01:59.642	cmrknujws00024hle61bdckim
cmrknuorh01td4hle4tovo6bk	watch3	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:59.646	2026-07-14 13:01:59.646	cmrknujwz00044hle5lxikvcu
cmrknuors01tf4hlesqevzadm	wache 3	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:59.657	2026-07-14 13:01:59.657	cmrknujwz00044hle5lxikvcu
cmrknuorv01th4hlezzcyv95v	IDEAPAD3	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:01:59.659	2026-07-14 13:01:59.659	cmrknujxm000b4hle4o2fwrvs
cmrknuorx01tj4hlebwnvqk6a	IPHONE 7 PLUS	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:59.661	2026-07-14 13:01:59.661	cmrkb3cy40000y9h6lftwhcie
cmrknuorz01tl4hlebscgjg2h	P6-U06	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:59.663	2026-07-14 13:01:59.663	cmrkb3cy40000y9h6lftwhcie
cmrknuos101tn4hle2go8iozz	POCO F4 4G	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:59.665	2026-07-14 13:01:59.665	cmrkb3cy40000y9h6lftwhcie
cmrknuos301tp4hlekxu19eof	INSPIRON N4030	cmrknujzd000t4hle1ujh33no	2026-07-14 13:01:59.667	2026-07-14 13:01:59.667	cmrknujxm000b4hle4o2fwrvs
cmrknuos601tr4hles92s9g9b	AN515-54	cmrknuk0500114hleha2g5pf3	2026-07-14 13:01:59.671	2026-07-14 13:01:59.671	cmrknujxm000b4hle4o2fwrvs
cmrknuos901tt4hlegu93u53h	A2341	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:59.674	2026-07-14 13:01:59.674	cmrkb3cy40000y9h6lftwhcie
cmrknuosb01tv4hle1pc7vqjq	PCG-388P	cmrknujyl000l4hlezisknz7b	2026-07-14 13:01:59.676	2026-07-14 13:01:59.676	cmrknujxm000b4hle4o2fwrvs
cmrknuosd01tx4hlexvphricb	GALAXY WATCH 5	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:59.678	2026-07-14 13:01:59.678	cmrknujwz00044hle5lxikvcu
cmrknuosg01tz4hlemm72p525	YT3-850M	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:01:59.68	2026-07-14 13:01:59.68	cmrkb3cyo0001y9h6bozaifdg
cmrknuosi01u14hlei8urr1ix	X6	cmrknujyo000m4hlecl948w9e	2026-07-14 13:01:59.682	2026-07-14 13:01:59.682	cmrkb3cy40000y9h6lftwhcie
cmrknuosk01u34hlen7ginb3t	TA-1105	cmrknuk1s001i4hleqifj4gnr	2026-07-14 13:01:59.685	2026-07-14 13:01:59.685	cmrkb3cy40000y9h6lftwhcie
cmrknuosn01u54hleydm4a9m6	SVF152C29L	cmrknujyl000l4hlezisknz7b	2026-07-14 13:01:59.687	2026-07-14 13:01:59.687	cmrknujxm000b4hle4o2fwrvs
cmrknuosq01u74hlegqj8yzj9	PRO X2	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:01:59.69	2026-07-14 13:01:59.69	cmrknujxm000b4hle4o2fwrvs
cmrknuoss01u94hlec2dq3d1z	TA-1046	cmrknuk1s001i4hleqifj4gnr	2026-07-14 13:01:59.693	2026-07-14 13:01:59.693	cmrkb3cy40000y9h6lftwhcie
cmrknuosv01ub4hleeskr3pwh	SM-G610F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:59.695	2026-07-14 13:01:59.695	cmrkb3cy40000y9h6lftwhcie
cmrknuosx01ud4hlesz2hd1y4	A53S	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:59.697	2026-07-14 13:01:59.697	cmrknujxm000b4hle4o2fwrvs
cmrknuosz01uf4hlehtbe45h2	CAMON CX AIR	cmrknuk2m001q4hlekwqta1w0	2026-07-14 13:01:59.7	2026-07-14 13:01:59.7	cmrkb3cy40000y9h6lftwhcie
cmrknuot201uh4hlew0p8rq7m	TA-1356	cmrknuk1s001i4hleqifj4gnr	2026-07-14 13:01:59.702	2026-07-14 13:01:59.702	cmrkb3cy40000y9h6lftwhcie
cmrknuot501uj4hle1s4eqsjk	15-N051S	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:01:59.705	2026-07-14 13:01:59.705	cmrknujxm000b4hle4o2fwrvs
cmrknuot701ul4hle5r1pbzed	SM-N970F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:59.707	2026-07-14 13:01:59.707	cmrkb3cy40000y9h6lftwhcie
cmrknuot901un4hleoz4upqhs	sm-s711b	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:59.709	2026-07-14 13:01:59.709	cmrkb3cy40000y9h6lftwhcie
cmrknuota01up4hle6hkz0ei9	A3A	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:59.711	2026-07-14 13:01:59.711	cmrknujxm000b4hle4o2fwrvs
cmrknuotc01ur4hlet5ehj8tv	Z OUITRA	cmrknujyl000l4hlezisknz7b	2026-07-14 13:01:59.713	2026-07-14 13:01:59.713	cmrkb3cy40000y9h6lftwhcie
cmrknuote01ut4hley51qqcmj	SVZ131A2JL	cmrknujyl000l4hlezisknz7b	2026-07-14 13:01:59.715	2026-07-14 13:01:59.715	cmrknujxm000b4hle4o2fwrvs
cmrknuotg01uv4hleia4hmm7y	TA-1164	cmrknuk1s001i4hleqifj4gnr	2026-07-14 13:01:59.717	2026-07-14 13:01:59.717	cmrkb3cy40000y9h6lftwhcie
cmrknuotj01ux4hleuv57yvr5	A1688	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:59.719	2026-07-14 13:01:59.719	cmrkb3cy40000y9h6lftwhcie
cmrknuotm01uz4hle16ab76kc	SM-A245F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:59.722	2026-07-14 13:01:59.722	cmrkb3cy40000y9h6lftwhcie
cmrknuoto01v14hleu4h4fg6g	REALME 8 PRO	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:59.724	2026-07-14 13:01:59.724	cmrkb3cy40000y9h6lftwhcie
cmrknuotq01v34hle2dfzc84r	REDMI NOTE7	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:59.726	2026-07-14 13:01:59.726	cmrkb3cy40000y9h6lftwhcie
cmrknuots01v54hleihbam0j8	SM-A405F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:59.728	2026-07-14 13:01:59.728	cmrkb3cy40000y9h6lftwhcie
cmrknuotu01v74hle2zi81xmv	PROBOOK 4530S	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:01:59.731	2026-07-14 13:01:59.731	cmrknujxm000b4hle4o2fwrvs
cmrknuotx01v94hlehaf1lup0	J610F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:59.733	2026-07-14 13:01:59.733	cmrkb3cy40000y9h6lftwhcie
cmrknuotz01vb4hlenazpbjrg	T460S	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:01:59.736	2026-07-14 13:01:59.736	cmrknujxm000b4hle4o2fwrvs
cmrknuou201vd4hleyqumfnat	REDMI 7	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:59.739	2026-07-14 13:01:59.739	cmrkb3cy40000y9h6lftwhcie
cmrknuou401vf4hleijyvk84f	A1502	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:59.741	2026-07-14 13:01:59.741	cmrknujxm000b4hle4o2fwrvs
cmrknuou701vh4hle7662xzlx	MDF-X	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:59.743	2026-07-14 13:01:59.743	cmrknujxm000b4hle4o2fwrvs
cmrknuoua01vj4hlegmisu14s	A2412	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:59.747	2026-07-14 13:01:59.747	cmrkb3cy40000y9h6lftwhcie
cmrknuouc01vl4hle669kne08	REDMI PAD	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:59.749	2026-07-14 13:01:59.749	cmrkb3cyo0001y9h6bozaifdg
cmrknuouf01vn4hleyvinhs1s	SERIES 4	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:59.751	2026-07-14 13:01:59.751	cmrknujwz00044hle5lxikvcu
cmrknuouh01vp4hle8wxziphl	REDMI NOTE 12S	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:59.753	2026-07-14 13:01:59.753	cmrkb3cy40000y9h6lftwhcie
cmrknuouk01vr4hleot1a30ut	A2008	cmrknuk1k001g4hlenhg99g16	2026-07-14 13:01:59.757	2026-07-14 13:01:59.757	cmrknujwz00044hle5lxikvcu
cmrknuoun01vt4hleo4xwewz9	DRA-LX5	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:59.759	2026-07-14 13:01:59.759	cmrkb3cy40000y9h6lftwhcie
cmrknuoup01vv4hleywmoasiw	SM-N8000	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:59.761	2026-07-14 13:01:59.761	cmrkb3cy40000y9h6lftwhcie
cmrknuour01vx4hle2btmetil	IDEAPAD 310	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:01:59.763	2026-07-14 13:01:59.763	cmrknujxm000b4hle4o2fwrvs
cmrknuout01vz4hlegv5fyspm	SM-A015F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:59.765	2026-07-14 13:01:59.765	cmrkb3cy40000y9h6lftwhcie
cmrknuouu01w14hle3g84v2hs	ELITE X2	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:01:59.767	2026-07-14 13:01:59.767	cmrknujxm000b4hle4o2fwrvs
cmrknuouw01w34hle0klvnpkc	SIGNATURE	cmrknuk1f001f4hle4qdiojps	2026-07-14 13:01:59.769	2026-07-14 13:01:59.769	cmrkb3cy40000y9h6lftwhcie
cmrknuouz01w54hleek93fks4	TA-1053	cmrknuk1s001i4hleqifj4gnr	2026-07-14 13:01:59.772	2026-07-14 13:01:59.772	cmrkb3cy40000y9h6lftwhcie
cmrknuov201w74hlefxvmx4i4	NITRO 7	cmrknuk0500114hleha2g5pf3	2026-07-14 13:01:59.774	2026-07-14 13:01:59.774	cmrknujxm000b4hle4o2fwrvs
cmrknuov401w94hledat5fr3u	SERIES 1	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:59.777	2026-07-14 13:01:59.777	cmrknujwz00044hle5lxikvcu
cmrknuov601wb4hlekwfu284g	BLN-L21	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:59.778	2026-07-14 13:01:59.778	cmrkb3cy40000y9h6lftwhcie
cmrknuov701wd4hlefhpxaavx	A1921	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:59.78	2026-07-14 13:01:59.78	cmrkb3cy40000y9h6lftwhcie
cmrknuov901wf4hleab7219h7	A-530f	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:59.782	2026-07-14 13:01:59.782	cmrkb3cy40000y9h6lftwhcie
cmrknuovb01wh4hle3kwbgllc	A1522	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:59.783	2026-07-14 13:01:59.783	cmrkb3cy40000y9h6lftwhcie
cmrknuovc01wj4hletmxx3vd1	SM-A536F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:59.785	2026-07-14 13:01:59.785	cmrkb3cy40000y9h6lftwhcie
cmrknuove01wl4hlere0z016j	GT-S5660	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:59.787	2026-07-14 13:01:59.787	cmrkb3cy40000y9h6lftwhcie
cmrknuovg01wn4hleshrbn524	13T PRO	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:59.789	2026-07-14 13:01:59.789	cmrkb3cy40000y9h6lftwhcie
cmrknuovi01wp4hlec5e9gbms	BLACK SHARK 3 PRO	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:59.791	2026-07-14 13:01:59.791	cmrkb3cy40000y9h6lftwhcie
cmrknuovk01wr4hlebajsntbc	A2338	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:59.793	2026-07-14 13:01:59.793	cmrknujxm000b4hle4o2fwrvs
cmrknuovm01wt4hlem1d92mhd	S532F	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:59.794	2026-07-14 13:01:59.794	cmrknujxm000b4hle4o2fwrvs
cmrknuovo01wv4hlep3c64tta	PRECISION 5530	cmrknujzd000t4hle1ujh33no	2026-07-14 13:01:59.796	2026-07-14 13:01:59.796	cmrknujxm000b4hle4o2fwrvs
cmrknuovq01wx4hlefe5vxc00	IDEAPAD L340	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:01:59.798	2026-07-14 13:01:59.798	cmrknujxm000b4hle4o2fwrvs
cmrknuovs01wz4hleasdyni17	TA-1119	cmrknuk1s001i4hleqifj4gnr	2026-07-14 13:01:59.8	2026-07-14 13:01:59.8	cmrkb3cy40000y9h6lftwhcie
cmrknuovu01x14hle5qr5eh7c	G-990b	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:59.802	2026-07-14 13:01:59.802	cmrkb3cy40000y9h6lftwhcie
cmrknuovw01x34hlemvzz4x9m	PCG-31111L	cmrknujyl000l4hlezisknz7b	2026-07-14 13:01:59.805	2026-07-14 13:01:59.805	cmrknujxm000b4hle4o2fwrvs
cmrknuovy01x54hlezhihgvxx	POCO F5 5G	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:59.807	2026-07-14 13:01:59.807	cmrkb3cy40000y9h6lftwhcie
cmrknuow001x74hledmemkyi9	INSPIRON N5010	cmrknujzd000t4hle1ujh33no	2026-07-14 13:01:59.809	2026-07-14 13:01:59.809	cmrknujxm000b4hle4o2fwrvs
cmrknuow201x94hle4b3zxv4d	X1 YOGA	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:01:59.811	2026-07-14 13:01:59.811	cmrknujxm000b4hle4o2fwrvs
cmrknuow401xb4hlewpuf30i2	A1969	cmrknuk1k001g4hlenhg99g16	2026-07-14 13:01:59.813	2026-07-14 13:01:59.813	cmrknujwz00044hle5lxikvcu
cmrknuow601xd4hle7sf8fd7m	MI 10T LITE	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:59.814	2026-07-14 13:01:59.814	cmrkb3cy40000y9h6lftwhcie
cmrknuow901xf4hlepcffnc4i	CRO-U00	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:59.817	2026-07-14 13:01:59.817	cmrkb3cy40000y9h6lftwhcie
cmrknuowc01xh4hlepcsibxs1	REDMI K30	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:59.821	2026-07-14 13:01:59.821	cmrkb3cy40000y9h6lftwhcie
cmrknuowf01xj4hlef757hc9b	mi  A3	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:59.823	2026-07-14 13:01:59.823	cmrkb3cy40000y9h6lftwhcie
cmrknuowh01xl4hlehehuucji	SM-A336	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:59.826	2026-07-14 13:01:59.826	cmrkb3cy40000y9h6lftwhcie
cmrknuowk01xn4hleeayo14lf	A33	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:59.828	2026-07-14 13:01:59.828	cmrkb3cy40000y9h6lftwhcie
cmrknuown01xp4hlefm4bdcl0	SM-F926B	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:59.831	2026-07-14 13:01:59.831	cmrkb3cy40000y9h6lftwhcie
cmrknuowq01xr4hletue2y8uw	SM-T515	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:59.834	2026-07-14 13:01:59.834	cmrkb3cyo0001y9h6bozaifdg
cmrknuowu01xt4hlep067wttp	پیکسل 4XL	cmrknuk0x00194hlevg4ydqsz	2026-07-14 13:01:59.838	2026-07-14 13:01:59.838	cmrkb3cy40000y9h6lftwhcie
cmrknuowx01xv4hlez01s1mbw	1	cmrknuk10001a4hleuaz2hxwo	2026-07-14 13:01:59.842	2026-07-14 13:01:59.842	cmrknujws00024hle61bdckim
cmrknuox001xx4hlei506p0vq	REDMI NOTE 13	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:59.844	2026-07-14 13:01:59.844	cmrkb3cy40000y9h6lftwhcie
cmrknuox301xz4hle14yakqcs	WRTB-WAH9L	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:59.847	2026-07-14 13:01:59.847	cmrknujxm000b4hle4o2fwrvs
cmrknuox501y14hle0dwumaq5	SM-G925	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:59.849	2026-07-14 13:01:59.849	cmrkb3cy40000y9h6lftwhcie
cmrknuox801y34hlezhf2p6g8	1 more	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:59.852	2026-07-14 13:01:59.852	cmrknujws00024hle61bdckim
cmrknuoxb01y54hlezlqq6eu1	MI BAND 4	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:59.856	2026-07-14 13:01:59.856	cmrknujwz00044hle5lxikvcu
cmrknuoxe01y74hleni4bagap	ENVY 360	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:01:59.858	2026-07-14 13:01:59.858	cmrknujxm000b4hle4o2fwrvs
cmrknuoxg01y94hleg4lzbo1q	VGN-FW490JAB	cmrknujyl000l4hlezisknz7b	2026-07-14 13:01:59.861	2026-07-14 13:01:59.861	cmrknujxm000b4hle4o2fwrvs
cmrknuoxi01yb4hle4go44b9m	ASPIRE V5-571	cmrknuk0500114hleha2g5pf3	2026-07-14 13:01:59.863	2026-07-14 13:01:59.863	cmrknujxm000b4hle4o2fwrvs
cmrknuoxk01yd4hle4xz14zwd	SM-W627	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:59.865	2026-07-14 13:01:59.865	cmrknujxm000b4hle4o2fwrvs
cmrknuoxn01yf4hleeph5mwgu	F5-573G	cmrknuk0500114hleha2g5pf3	2026-07-14 13:01:59.867	2026-07-14 13:01:59.867	cmrknujxm000b4hle4o2fwrvs
cmrknuoxq01yh4hlevx7morji	1601	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:59.87	2026-07-14 13:01:59.87	cmrknujxm000b4hle4o2fwrvs
cmrknuoxt01yj4hlemwy67fw9	B590	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:01:59.873	2026-07-14 13:01:59.873	cmrknujxm000b4hle4o2fwrvs
cmrknuoxv01yl4hle4p1qmwbq	G985F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:59.876	2026-07-14 13:01:59.876	cmrkb3cy40000y9h6lftwhcie
cmrknuoxy01yn4hleweo1zxdf	REDMI S2	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:59.878	2026-07-14 13:01:59.878	cmrkb3cy40000y9h6lftwhcie
cmrknuoy001yp4hle8y4i0spa	A 1586	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:59.88	2026-07-14 13:01:59.88	cmrkb3cy40000y9h6lftwhcie
cmrknuoy201yr4hlev5acvs63	moto x4	cmrknujz5000r4hleshjq47jw	2026-07-14 13:01:59.882	2026-07-14 13:01:59.882	cmrkb3cy40000y9h6lftwhcie
cmrknuoy601yt4hleb7gemuwt	p768	cmrknuk0p00174hleoejfscfb	2026-07-14 13:01:59.886	2026-07-14 13:01:59.886	cmrkb3cy40000y9h6lftwhcie
cmrknuoy901yv4hle459n8bic	A5500HV	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:01:59.889	2026-07-14 13:01:59.889	cmrkb3cyo0001y9h6bozaifdg
cmrknuoyb01yx4hlepbqolnr3	SM-A736B	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:59.892	2026-07-14 13:01:59.892	cmrkb3cy40000y9h6lftwhcie
cmrknuoyd01yz4hleth2rg185	SM-G532F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:59.894	2026-07-14 13:01:59.894	cmrkb3cy40000y9h6lftwhcie
cmrknuoyg01z14hleebzj9254	X555B	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:59.896	2026-07-14 13:01:59.896	cmrknujxm000b4hle4o2fwrvs
cmrknuoyi01z34hlezw0yclnm	SM-P585	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:59.899	2026-07-14 13:01:59.899	cmrkb3cy40000y9h6lftwhcie
cmrknuoyk01z54hle118erldi	X00ID	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:59.901	2026-07-14 13:01:59.901	cmrkb3cy40000y9h6lftwhcie
cmrknuoyo01z74hle5pl0uxhk	A2411	cmrknujzo000w4hlesj7fng18	2026-07-14 13:01:59.904	2026-07-14 13:01:59.904	cmrkb3cy40000y9h6lftwhcie
cmrknuoyr01z94hlevtuln4zt	MI NOTE 2	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:59.907	2026-07-14 13:01:59.907	cmrkb3cy40000y9h6lftwhcie
cmrknuoyt01zb4hlett2em0tq	SM-A920F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:59.91	2026-07-14 13:01:59.91	cmrkb3cy40000y9h6lftwhcie
cmrknuoyv01zd4hle18yuiesb	PCG-8112L	cmrknujyl000l4hlezisknz7b	2026-07-14 13:01:59.912	2026-07-14 13:01:59.912	cmrknujxm000b4hle4o2fwrvs
cmrknuoyy01zf4hlelsmb3kcv	sm-g935fd	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:59.914	2026-07-14 13:01:59.914	cmrkb3cy40000y9h6lftwhcie
cmrknuoz001zh4hleah5s0tdk	TA-1116	cmrknuk1s001i4hleqifj4gnr	2026-07-14 13:01:59.916	2026-07-14 13:01:59.916	cmrkb3cy40000y9h6lftwhcie
cmrknuoz401zj4hlejgvuov8w	sm-a528s	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:59.921	2026-07-14 13:01:59.921	cmrkb3cy40000y9h6lftwhcie
cmrknuoz701zl4hle5b48eyol	SM-J700H	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:59.924	2026-07-14 13:01:59.924	cmrkb3cy40000y9h6lftwhcie
cmrknuoza01zn4hleklwdx8ju	POCO F4 5G	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:59.926	2026-07-14 13:01:59.926	cmrkb3cy40000y9h6lftwhcie
cmrknuozc01zp4hlenm83g5es	MI BOOK AIR	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:59.928	2026-07-14 13:01:59.928	cmrknujxm000b4hle4o2fwrvs
cmrknuoze01zr4hle9sjf4way	G731G	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:59.93	2026-07-14 13:01:59.93	cmrknujxm000b4hle4o2fwrvs
cmrknuozg01zt4hlebqo5ndfn	SM-A217F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:59.932	2026-07-14 13:01:59.932	cmrkb3cy40000y9h6lftwhcie
cmrknuozi01zv4hleq6hemejw	12C	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:59.934	2026-07-14 13:01:59.934	cmrkb3cy40000y9h6lftwhcie
cmrknuozl01zx4hlecaxjh0xt	M7600Q	cmrknujyb000i4hleung9zde3	2026-07-14 13:01:59.937	2026-07-14 13:01:59.937	cmrknujxm000b4hle4o2fwrvs
cmrknuozo01zz4hlestr99g3q	SM-J710F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:59.94	2026-07-14 13:01:59.94	cmrkb3cy40000y9h6lftwhcie
cmrknuozr02014hlemsvguts6	TERAVELMATE 4330	cmrknuk0500114hleha2g5pf3	2026-07-14 13:01:59.943	2026-07-14 13:01:59.943	cmrknujxm000b4hle4o2fwrvs
cmrknuozu02034hlefcrllk5x	NBB-WAH9	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:59.946	2026-07-14 13:01:59.946	cmrknujxm000b4hle4o2fwrvs
cmrknuozw02054hleuqjdtsis	G15	cmrknujzd000t4hle1ujh33no	2026-07-14 13:01:59.949	2026-07-14 13:01:59.949	cmrknujxm000b4hle4o2fwrvs
cmrknup0002074hle0mlfsl8h	SM-T875	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:59.952	2026-07-14 13:01:59.952	cmrkb3cyo0001y9h6bozaifdg
cmrknup0302094hlemput8ell	SM-A032F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:59.955	2026-07-14 13:01:59.955	cmrkb3cy40000y9h6lftwhcie
cmrknup05020b4hleqsvzlmel	C35	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:59.957	2026-07-14 13:01:59.957	cmrkb3cy40000y9h6lftwhcie
cmrknup07020d4hle9zq4n51y	2PZ4100	cmrknujzy000z4hlef0vui8me	2026-07-14 13:01:59.959	2026-07-14 13:01:59.959	cmrkb3cy40000y9h6lftwhcie
cmrknup09020f4hlehk5avgou	MI 13 LITE	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:59.961	2026-07-14 13:01:59.961	cmrkb3cy40000y9h6lftwhcie
cmrknup0b020h4hle7y0pzan7	SM-P601	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:59.963	2026-07-14 13:01:59.963	cmrkb3cyo0001y9h6bozaifdg
cmrknup0c020j4hle528wz4mt	SM-N750	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:01:59.965	2026-07-14 13:01:59.965	cmrkb3cy40000y9h6lftwhcie
cmrknup0e020l4hlesv7ygp65	POCO F5 PRO	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:59.967	2026-07-14 13:01:59.967	cmrkb3cy40000y9h6lftwhcie
cmrknup0h020n4hlekcq58ukm	ASPIRE 5742	cmrknuk0500114hleha2g5pf3	2026-07-14 13:01:59.97	2026-07-14 13:01:59.97	cmrknujxm000b4hle4o2fwrvs
cmrknup0k020p4hlebbko1xos	MIBRO LITE 2	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:59.972	2026-07-14 13:01:59.972	cmrknujwz00044hle5lxikvcu
cmrknup0m020r4hle2wjo714d	ASPIRE R3	cmrknuk0500114hleha2g5pf3	2026-07-14 13:01:59.974	2026-07-14 13:01:59.974	cmrknujxm000b4hle4o2fwrvs
cmrknup0o020t4hle1ydhrjrc	POCO X5 PRO 5G	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:01:59.976	2026-07-14 13:01:59.976	cmrkb3cy40000y9h6lftwhcie
cmrknup0q020v4hle825d07cu	PCG-61212W	cmrknujyl000l4hlezisknz7b	2026-07-14 13:01:59.978	2026-07-14 13:01:59.978	cmrknujxm000b4hle4o2fwrvs
cmrknup0s020x4hlezy461a5k	G700-U10	cmrknujzi000u4hle2av7btwx	2026-07-14 13:01:59.98	2026-07-14 13:01:59.98	cmrkb3cy40000y9h6lftwhcie
cmrknup0u020z4hlevmeyzuyx	SVF14N16SGS	cmrknujyl000l4hlezisknz7b	2026-07-14 13:01:59.982	2026-07-14 13:01:59.982	cmrknujxm000b4hle4o2fwrvs
cmrknup0x02114hle0kz7f97r	E5-531G	cmrknuk0500114hleha2g5pf3	2026-07-14 13:01:59.985	2026-07-14 13:01:59.985	cmrknujxm000b4hle4o2fwrvs
cmrknup1102134hlexx3bdltv	H930	cmrknuk0p00174hleoejfscfb	2026-07-14 13:01:59.989	2026-07-14 13:01:59.989	cmrkb3cy40000y9h6lftwhcie
cmrknup1302154hle7qeokzhg	ASPIRE E1-510	cmrknuk0500114hleha2g5pf3	2026-07-14 13:01:59.992	2026-07-14 13:01:59.992	cmrknujxm000b4hle4o2fwrvs
cmrknup1602174hleiecuvhn8	PRO 7 PLUS	cmrknujy4000h4hlefueee7c4	2026-07-14 13:01:59.994	2026-07-14 13:01:59.994	cmrknujxm000b4hle4o2fwrvs
cmrknup1802194hlesocugntg	PCG-6S2L	cmrknujyl000l4hlezisknz7b	2026-07-14 13:01:59.997	2026-07-14 13:01:59.997	cmrknujxm000b4hle4o2fwrvs
cmrknup1b021b4hlehlumsad1	SM-A310F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:00	2026-07-14 13:02:00	cmrkb3cy40000y9h6lftwhcie
cmrknup1e021d4hlenva54uit	A310	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:00.002	2026-07-14 13:02:00.002	cmrkb3cy40000y9h6lftwhcie
cmrknup1h021f4hlemacxvy8i	S550CM	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:00.006	2026-07-14 13:02:00.006	cmrknujxm000b4hle4o2fwrvs
cmrknup1k021h4hle4eok4ehy	S550F	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:00.009	2026-07-14 13:02:00.009	cmrknujxm000b4hle4o2fwrvs
cmrknup1n021j4hle6pzh458t	K550V	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:00.012	2026-07-14 13:02:00.012	cmrknujxm000b4hle4o2fwrvs
cmrknup1p021l4hlews5pxao1	G500	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:02:00.014	2026-07-14 13:02:00.014	cmrknujxm000b4hle4o2fwrvs
cmrknup1r021n4hle36aj3sru	V6545	cmrknujys000n4hlezjygamno	2026-07-14 13:02:00.016	2026-07-14 13:02:00.016	cmrknujxm000b4hle4o2fwrvs
cmrknup1t021p4hledvtjwbpn	A1864	cmrknujzo000w4hlesj7fng18	2026-07-14 13:02:00.017	2026-07-14 13:02:00.017	cmrkb3cy40000y9h6lftwhcie
cmrknup1w021r4hleo3gqo31j	MI A1	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:00.02	2026-07-14 13:02:00.02	cmrkb3cy40000y9h6lftwhcie
cmrknup1y021t4hlet9lst889	SM-M336B	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:00.023	2026-07-14 13:02:00.023	cmrkb3cy40000y9h6lftwhcie
cmrknup20021v4hleuecol1je	SM-J250F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:00.025	2026-07-14 13:02:00.025	cmrkb3cy40000y9h6lftwhcie
cmrknup22021x4hle3znnqwmr	SVF152A29W	cmrknujyl000l4hlezisknz7b	2026-07-14 13:02:00.027	2026-07-14 13:02:00.027	cmrknujxm000b4hle4o2fwrvs
cmrknup24021z4hle8yuv59kt	HAYLOU-LS02	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:00.029	2026-07-14 13:02:00.029	cmrknujwz00044hle5lxikvcu
cmrknup2602214hle93yq38st	NBDE-WFH9	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:00.03	2026-07-14 13:02:00.03	cmrknujxm000b4hle4o2fwrvs
cmrknup2802234hleyolkz93c	SM-T531	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:00.032	2026-07-14 13:02:00.032	cmrkb3cyo0001y9h6bozaifdg
cmrknup2902254hlep1coad7e	DRA-LX2	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:00.034	2026-07-14 13:02:00.034	cmrkb3cy40000y9h6lftwhcie
cmrknup2b02274hlenjyb2alo	SM-N950F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:00.036	2026-07-14 13:02:00.036	cmrkb3cy40000y9h6lftwhcie
cmrknup2e02294hlebx7kmswa	T-REX PRO	cmrknuk1k001g4hlenhg99g16	2026-07-14 13:02:00.038	2026-07-14 13:02:00.038	cmrknujwz00044hle5lxikvcu
cmrknup2g022b4hleiusrqsp2	SM-J120F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:00.04	2026-07-14 13:02:00.04	cmrkb3cy40000y9h6lftwhcie
cmrknup2i022d4hleoaxoktiw	SVD112A1SW	cmrknujyl000l4hlezisknz7b	2026-07-14 13:02:00.042	2026-07-14 13:02:00.042	cmrknujxm000b4hle4o2fwrvs
cmrknup2k022f4hlejutorqeo	A1914	cmrknuk1k001g4hlenhg99g16	2026-07-14 13:02:00.044	2026-07-14 13:02:00.044	cmrknujwz00044hle5lxikvcu
cmrknup2m022h4hlevcr9ji2y	BNE-LX1	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:00.046	2026-07-14 13:02:00.046	cmrkb3cy40000y9h6lftwhcie
cmrknup2o022j4hle2dvzriqw	A1524	cmrknujzo000w4hlesj7fng18	2026-07-14 13:02:00.048	2026-07-14 13:02:00.048	cmrkb3cy40000y9h6lftwhcie
cmrknup2q022l4hlepofk0may	SM-G570F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:00.05	2026-07-14 13:02:00.05	cmrkb3cy40000y9h6lftwhcie
cmrknup2s022n4hle9hmjepic	SM-S908E	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:00.052	2026-07-14 13:02:00.052	cmrkb3cy40000y9h6lftwhcie
cmrknup2u022p4hlexx6wlb4k	SM-A326B	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:00.055	2026-07-14 13:02:00.055	cmrkb3cy40000y9h6lftwhcie
cmrknup2x022r4hle2tqk9azx	A1286	cmrknujzo000w4hlesj7fng18	2026-07-14 13:02:00.057	2026-07-14 13:02:00.057	cmrknujxm000b4hle4o2fwrvs
cmrknup2z022t4hle4x6s5x2l	M250E	cmrknuk0p00174hleoejfscfb	2026-07-14 13:02:00.06	2026-07-14 13:02:00.06	cmrkb3cy40000y9h6lftwhcie
cmrknup31022v4hlem3g40uxy	watch 2	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:00.062	2026-07-14 13:02:00.062	cmrknujwz00044hle5lxikvcu
cmrknup33022x4hlesb3n1v5g	TB-8505X	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:02:00.064	2026-07-14 13:02:00.064	cmrkb3cyo0001y9h6bozaifdg
cmrknup35022z4hleh31b1mjj	THINKPAD X240	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:02:00.066	2026-07-14 13:02:00.066	cmrknujxm000b4hle4o2fwrvs
cmrknup3802314hlejnb2vka4	TA-1041	cmrknuk1s001i4hleqifj4gnr	2026-07-14 13:02:00.068	2026-07-14 13:02:00.068	cmrkb3cy40000y9h6lftwhcie
cmrknup3a02334hle2rftswok	REDMI K40	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:00.071	2026-07-14 13:02:00.071	cmrkb3cy40000y9h6lftwhcie
cmrknup3d02354hle1h6gccsv	ADOL14Z	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:00.074	2026-07-14 13:02:00.074	cmrknujxm000b4hle4o2fwrvs
cmrknup3g02374hlemfiw9gee	ADOL14Z (تبلت)	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:00.076	2026-07-14 13:02:00.076	cmrkb3cyo0001y9h6bozaifdg
cmrknup3k02394hlecaqyyk3n	13UITRA	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:00.08	2026-07-14 13:02:00.08	cmrkb3cy40000y9h6lftwhcie
cmrknup3m023b4hleo69lt1jr	PROBOOK 4540S	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:02:00.082	2026-07-14 13:02:00.082	cmrknujxm000b4hle4o2fwrvs
cmrknup3p023d4hlex3uvmfu0	A1952	cmrknuk1k001g4hlenhg99g16	2026-07-14 13:02:00.085	2026-07-14 13:02:00.085	cmrknujwz00044hle5lxikvcu
cmrknup3s023f4hle1jrkbbxk	S330F	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:00.088	2026-07-14 13:02:00.088	cmrknujxm000b4hle4o2fwrvs
cmrknup3v023h4hlel5hnih5x	A1612	cmrknuk1k001g4hlenhg99g16	2026-07-14 13:02:00.092	2026-07-14 13:02:00.092	cmrknujwz00044hle5lxikvcu
cmrknup3z023j4hlesuzcxbs1	D100LVWPP	cmrknujzy000z4hlef0vui8me	2026-07-14 13:02:00.095	2026-07-14 13:02:00.095	cmrkb3cy40000y9h6lftwhcie
cmrknup42023l4hlec3lgi8lc	GALAXY WATCH3	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:00.098	2026-07-14 13:02:00.098	cmrknujwz00044hle5lxikvcu
cmrknup46023n4hlemdueob5c	K555D	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:00.102	2026-07-14 13:02:00.102	cmrknujxm000b4hle4o2fwrvs
cmrknup4a023p4hlebof7ab6g	SM-N960F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:00.106	2026-07-14 13:02:00.106	cmrkb3cy40000y9h6lftwhcie
cmrknup4f023r4hlejgvf24ao	smart watch2	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:00.111	2026-07-14 13:02:00.111	cmrknujwz00044hle5lxikvcu
cmrknup4j023t4hletqqrg14z	V330-15LKB	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:02:00.116	2026-07-14 13:02:00.116	cmrknujxm000b4hle4o2fwrvs
cmrknup4p023v4hlettxwd6v0	DUA-L22	cmrknujyo000m4hlecl948w9e	2026-07-14 13:02:00.121	2026-07-14 13:02:00.121	cmrkb3cy40000y9h6lftwhcie
cmrknup4x023x4hlezttbv05b	fit2 (ساعت)	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:00.129	2026-07-14 13:02:00.129	cmrknujwz00044hle5lxikvcu
cmrknup58023z4hleqeerjf1x	D2306	cmrknujyl000l4hlezisknz7b	2026-07-14 13:02:00.14	2026-07-14 13:02:00.14	cmrkb3cy40000y9h6lftwhcie
cmrknup5e02414hlerawi2v0c	A2643	cmrknujzo000w4hlesj7fng18	2026-07-14 13:02:00.147	2026-07-14 13:02:00.147	cmrkb3cy40000y9h6lftwhcie
cmrknup5l02434hle1x0wzxh5	A2040	cmrknuk1k001g4hlenhg99g16	2026-07-14 13:02:00.153	2026-07-14 13:02:00.153	cmrknujwz00044hle5lxikvcu
cmrknup5r02454hle7hady2as	WI503Q	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:00.16	2026-07-14 13:02:00.16	cmrknujwz00044hle5lxikvcu
cmrknup5x02474hlespum3nqk	PAD 5	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:00.165	2026-07-14 13:02:00.165	cmrkb3cyo0001y9h6bozaifdg
cmrknup6302494hlecb99pfuw	YT3-X50M	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:02:00.171	2026-07-14 13:02:00.171	cmrkb3cyo0001y9h6bozaifdg
cmrknup6a024b4hle485n79r1	15-K211NE	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:02:00.178	2026-07-14 13:02:00.178	cmrknujxm000b4hle4o2fwrvs
cmrknup6f024d4hle9aemmgi0	SPECTRE X360	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:02:00.184	2026-07-14 13:02:00.184	cmrknujxm000b4hle4o2fwrvs
cmrknup6m024f4hlepq1k1p76	A1586	cmrknujzo000w4hlesj7fng18	2026-07-14 13:02:00.19	2026-07-14 13:02:00.19	cmrkb3cy40000y9h6lftwhcie
cmrknup6t024h4hlew0fopi95	GTS2	cmrknuk1k001g4hlenhg99g16	2026-07-14 13:02:00.197	2026-07-14 13:02:00.197	cmrknujwz00044hle5lxikvcu
cmrknup6z024j4hlen4lnzqxc	MI 10 LITE	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:00.203	2026-07-14 13:02:00.203	cmrkb3cy40000y9h6lftwhcie
cmrknup76024l4hle4s4i1rp6	PCG-7181W	cmrknujyl000l4hlezisknz7b	2026-07-14 13:02:00.21	2026-07-14 13:02:00.21	cmrknujxm000b4hle4o2fwrvs
cmrknup7c024n4hlexi85aknz	G610-U20	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:00.216	2026-07-14 13:02:00.216	cmrkb3cy40000y9h6lftwhcie
cmrknup7i024p4hlet8kffh2a	SATELLITE L755-M1DU	cmrknuk0h00154hlealpjijvx	2026-07-14 13:02:00.222	2026-07-14 13:02:00.222	cmrknujxm000b4hle4o2fwrvs
cmrknup7p024r4hler1vu7lxa	H324T	cmrknuk0p00174hleoejfscfb	2026-07-14 13:02:00.229	2026-07-14 13:02:00.229	cmrkb3cy40000y9h6lftwhcie
cmrknup7v024t4hle5tis4shu	oplq100	cmrknujzy000z4hlef0vui8me	2026-07-14 13:02:00.235	2026-07-14 13:02:00.235	cmrkb3cy40000y9h6lftwhcie
cmrknup82024v4hlecl0ymucm	MI 11 LITE NE	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:00.242	2026-07-14 13:02:00.242	cmrkb3cy40000y9h6lftwhcie
cmrknup8a024x4hlex0szw4z8	GT-L9505	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:00.25	2026-07-14 13:02:00.25	cmrkb3cy40000y9h6lftwhcie
cmrknup8i024z4hlekl66ljo0	SM-R800	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:00.259	2026-07-14 13:02:00.259	cmrknujwz00044hle5lxikvcu
cmrknup8q02514hlec0gqil40	A2166	cmrknuk1k001g4hlenhg99g16	2026-07-14 13:02:00.266	2026-07-14 13:02:00.266	cmrknujwz00044hle5lxikvcu
cmrknup8x02534hleem7ncibm	PM0270	cmrknujyl000l4hlezisknz7b	2026-07-14 13:02:00.273	2026-07-14 13:02:00.273	cmrkb3cy40000y9h6lftwhcie
cmrknup9402554hle3htv4mnd	XPERIA Z	cmrknujyl000l4hlezisknz7b	2026-07-14 13:02:00.281	2026-07-14 13:02:00.281	cmrkb3cy40000y9h6lftwhcie
cmrknup9c02574hleksj8k4lz	SM-T825	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:00.288	2026-07-14 13:02:00.288	cmrkb3cyo0001y9h6bozaifdg
cmrknup9k02594hleon2wjfms	SVF142A29W	cmrknujyl000l4hlezisknz7b	2026-07-14 13:02:00.296	2026-07-14 13:02:00.296	cmrknujxm000b4hle4o2fwrvs
cmrknup9q025b4hlet115qxqx	SERIES 2	cmrknujzo000w4hlesj7fng18	2026-07-14 13:02:00.303	2026-07-14 13:02:00.303	cmrknujwz00044hle5lxikvcu
cmrknup9y025d4hleiefpzj5z	ASPIRE 2930	cmrknuk0500114hleha2g5pf3	2026-07-14 13:02:00.31	2026-07-14 13:02:00.31	cmrknujxm000b4hle4o2fwrvs
cmrknupa4025f4hleuoek3fai	IDEA PAD 330	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:02:00.317	2026-07-14 13:02:00.317	cmrknujxm000b4hle4o2fwrvs
cmrknupad025h4hlej4a3jbe6	HAYLOU SOLAR	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:00.325	2026-07-14 13:02:00.325	cmrknujwz00044hle5lxikvcu
cmrknupak025j4hledqkjbfw5	15-N020SE	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:02:00.332	2026-07-14 13:02:00.332	cmrknujxm000b4hle4o2fwrvs
cmrknupar025l4hleu749vmgg	REALME 8	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:00.339	2026-07-14 13:02:00.339	cmrkb3cy40000y9h6lftwhcie
cmrknupay025n4hlei8wtzydz	G50-45	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:02:00.346	2026-07-14 13:02:00.346	cmrknujxm000b4hle4o2fwrvs
cmrknupb6025p4hle2vtk35y1	Mi Portable Electric Air Compressor	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:00.354	2026-07-14 13:02:00.354	cmrknujwv00034hlebaerivwe
cmrknupbd025r4hlex0eq2mgq	G62-B53SE	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:02:00.361	2026-07-14 13:02:00.361	cmrknujxm000b4hle4o2fwrvs
cmrknupbl025t4hleilxveawn	P008	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:00.369	2026-07-14 13:02:00.369	cmrkb3cy40000y9h6lftwhcie
cmrknupbs025v4hleu57rf6h5	PCG-7171L	cmrknujyl000l4hlezisknz7b	2026-07-14 13:02:00.376	2026-07-14 13:02:00.376	cmrknujxm000b4hle4o2fwrvs
cmrknupby025x4hle6qu0l11e	SM-G990E	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:00.382	2026-07-14 13:02:00.382	cmrkb3cy40000y9h6lftwhcie
cmrknupc5025z4hlectqrrtub	GEAR SPORT	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:00.389	2026-07-14 13:02:00.389	cmrknujwz00044hle5lxikvcu
cmrknupcc02614hleusa80n0a	REDMI 9NFC	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:00.396	2026-07-14 13:02:00.396	cmrkb3cy40000y9h6lftwhcie
cmrknupck02634hlegn9w2wy1	REDMI 10C	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:00.404	2026-07-14 13:02:00.404	cmrkb3cy40000y9h6lftwhcie
cmrknupcs02654hleg8lky3c1	WATCH 2 LITE	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:00.412	2026-07-14 13:02:00.412	cmrkb3cy40000y9h6lftwhcie
cmrknupd002674hlet9o3auz8	12T PRO	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:00.421	2026-07-14 13:02:00.421	cmrkb3cy40000y9h6lftwhcie
cmrknupd802694hle9ifv6nu9	P109F	cmrknuk22001k4hlewvssmg0i	2026-07-14 13:02:00.428	2026-07-14 13:02:00.428	cmrknujxm000b4hle4o2fwrvs
cmrknupdf026b4hles87ll4wm	REDMI NOTE 11SE	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:00.435	2026-07-14 13:02:00.435	cmrkb3cy40000y9h6lftwhcie
cmrknupdo026d4hletaog9y9y	SM-T585	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:00.444	2026-07-14 13:02:00.444	cmrkb3cyo0001y9h6bozaifdg
cmrknupdv026f4hlexbzeua3g	SM-A525F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:00.451	2026-07-14 13:02:00.451	cmrkb3cy40000y9h6lftwhcie
cmrknupe3026h4hleqraahhyv	MIBRO WATCH X1	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:00.459	2026-07-14 13:02:00.459	cmrknujwz00044hle5lxikvcu
cmrknupea026j4hleg0hgs8ed	REDMI K30 PRO	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:00.467	2026-07-14 13:02:00.467	cmrkb3cy40000y9h6lftwhcie
cmrknupei026l4hleoscqxgb5	poco f5	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:00.474	2026-07-14 13:02:00.474	cmrkb3cy40000y9h6lftwhcie
cmrknupeo026n4hleryve3g0c	V15	cmrknujzl000v4hle1n0o4b2k	2026-07-14 13:02:00.481	2026-07-14 13:02:00.481	cmrkb3cy40000y9h6lftwhcie
cmrknupew026p4hle6u9wtu5t	2AMQ6-LS05	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:00.488	2026-07-14 13:02:00.488	cmrknujwz00044hle5lxikvcu
cmrknupf3026r4hlecvtt58s5	60044	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:02:00.495	2026-07-14 13:02:00.495	cmrkb3cyo0001y9h6bozaifdg
cmrknupfa026t4hle6gx2pp5k	S533E	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:00.502	2026-07-14 13:02:00.502	cmrknujxm000b4hle4o2fwrvs
cmrknupfi026v4hle73mdjkjd	GL503V	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:00.51	2026-07-14 13:02:00.51	cmrkb3cy40000y9h6lftwhcie
cmrknupfp026x4hletwsuokre	MI PAD SE	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:00.517	2026-07-14 13:02:00.517	cmrkb3cyo0001y9h6bozaifdg
cmrknupfx026z4hleof46mmpe	SM-P585 (تبلت)	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:00.526	2026-07-14 13:02:00.526	cmrkb3cyo0001y9h6bozaifdg
cmrknupg802714hlego0mj2e9	REDMI WATCH LITE	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:00.536	2026-07-14 13:02:00.536	cmrknujwz00044hle5lxikvcu
cmrknupgh02734hleynkmsze1	TP301U	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:00.545	2026-07-14 13:02:00.545	cmrknujxm000b4hle4o2fwrvs
cmrknupgo02754hlelq9e5pvr	T200T	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:00.552	2026-07-14 13:02:00.552	cmrknujxm000b4hle4o2fwrvs
cmrknupgw02774hle6n7m28ey	D16H1	cmrknuk0500114hleha2g5pf3	2026-07-14 13:02:00.56	2026-07-14 13:02:00.56	cmrknujxm000b4hle4o2fwrvs
cmrknuph302794hle3m56ydk2	BOD-WFH9	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:00.567	2026-07-14 13:02:00.567	cmrknujxm000b4hle4o2fwrvs
cmrknuphb027b4hlep5um03p6	OPMG200	cmrknujzy000z4hlef0vui8me	2026-07-14 13:02:00.575	2026-07-14 13:02:00.575	cmrkb3cy40000y9h6lftwhcie
cmrknuphi027d4hlejqfw7e1q	IDEAPAD L3 15IML05 (لپ تاپ)	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:02:00.582	2026-07-14 13:02:00.582	cmrknujxm000b4hle4o2fwrvs
cmrknupht027f4hle38yi9ml4	SM-T505N	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:00.593	2026-07-14 13:02:00.593	cmrkb3cyo0001y9h6bozaifdg
cmrknuphz027h4hleww2w38gy	NBD-WDH9	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:00.599	2026-07-14 13:02:00.599	cmrknujxm000b4hle4o2fwrvs
cmrknupi6027j4hle1psmjnjj	HRY-LX1MEB	cmrknujyo000m4hlecl948w9e	2026-07-14 13:02:00.606	2026-07-14 13:02:00.606	cmrkb3cy40000y9h6lftwhcie
cmrknupid027l4hle20zzss5u	GT-N8000	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:00.614	2026-07-14 13:02:00.614	cmrkb3cyo0001y9h6bozaifdg
cmrknupim027n4hled19h240k	SM-A127F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:00.622	2026-07-14 13:02:00.622	cmrkb3cy40000y9h6lftwhcie
cmrknupit027p4hle2gaa62ug	REDMI NOTE 9T 5G	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:00.629	2026-07-14 13:02:00.629	cmrkb3cy40000y9h6lftwhcie
cmrknupj1027r4hlevg71y0b7	A1332	cmrknujzo000w4hlesj7fng18	2026-07-14 13:02:00.638	2026-07-14 13:02:00.638	cmrkb3cy40000y9h6lftwhcie
cmrknupj9027t4hle7p7wpqj7	POCO F4 GT	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:00.645	2026-07-14 13:02:00.645	cmrkb3cy40000y9h6lftwhcie
cmrknupjg027v4hle4kojt019	UM3402Y	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:00.652	2026-07-14 13:02:00.652	cmrknujxm000b4hle4o2fwrvs
cmrknupjn027x4hlez8bzciec	REDMI NOTE 12 PRO 4G	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:00.659	2026-07-14 13:02:00.659	cmrkb3cy40000y9h6lftwhcie
cmrknupjt027z4hlenez65bkz	REDMI NOTE 12 PRO 5G	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:00.665	2026-07-14 13:02:00.665	cmrkb3cy40000y9h6lftwhcie
cmrknupk002814hlevf531i90	MIBRO LITE	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:00.672	2026-07-14 13:02:00.672	cmrknujwz00044hle5lxikvcu
cmrknupk602834hlephcr2me4	M80T	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:00.679	2026-07-14 13:02:00.679	cmrkb3cyo0001y9h6bozaifdg
cmrknupkd02854hle017e1tjx	S10-101U	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:00.685	2026-07-14 13:02:00.685	cmrkb3cyo0001y9h6bozaifdg
cmrknupkk02874hley5ft1zo0	MED-LX9	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:00.692	2026-07-14 13:02:00.692	cmrkb3cy40000y9h6lftwhcie
cmrknupkr02894hlejz8ikw3d	SM-A600FN	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:00.699	2026-07-14 13:02:00.699	cmrkb3cy40000y9h6lftwhcie
cmrknupky028b4hled8745j9h	REDMI NOTE 12	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:00.706	2026-07-14 13:02:00.706	cmrkb3cy40000y9h6lftwhcie
cmrknupl5028d4hled7u0kaga	SM-T295 (تبلت)	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:00.713	2026-07-14 13:02:00.713	cmrkb3cyo0001y9h6bozaifdg
cmrknuplo028f4hlebk596whx	T1_701U	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:00.732	2026-07-14 13:02:00.732	cmrkb3cyo0001y9h6bozaifdg
cmrknuplw028h4hlet0urywaz	G512LI	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:00.741	2026-07-14 13:02:00.741	cmrknujxm000b4hle4o2fwrvs
cmrknupm4028j4hle46zg3xgj	SM-R84D	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:00.748	2026-07-14 13:02:00.748	cmrknujwz00044hle5lxikvcu
cmrknupme028l4hlen7yf2cl6	2PXH300	cmrknujzy000z4hlef0vui8me	2026-07-14 13:02:00.758	2026-07-14 13:02:00.758	cmrkb3cy40000y9h6lftwhcie
cmrknupml028n4hleqqpx118m	INSPIRON 15R_5521	cmrknujzd000t4hle1ujh33no	2026-07-14 13:02:00.765	2026-07-14 13:02:00.765	cmrknujxm000b4hle4o2fwrvs
cmrknupmt028p4hlewc2o4l85	SM-R380	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:00.773	2026-07-14 13:02:00.773	cmrknujwz00044hle5lxikvcu
cmrknupn1028r4hlec4obb8q3	A1706	cmrknujzo000w4hlesj7fng18	2026-07-14 13:02:00.781	2026-07-14 13:02:00.781	cmrknujxm000b4hle4o2fwrvs
cmrknupn9028t4hleq99mm966	2PYA210	cmrknujzy000z4hlef0vui8me	2026-07-14 13:02:00.789	2026-07-14 13:02:00.789	cmrkb3cy40000y9h6lftwhcie
cmrknupni028v4hle96ukzhtw	LATITUDE E5530	cmrknujzd000t4hle1ujh33no	2026-07-14 13:02:00.798	2026-07-14 13:02:00.798	cmrknujxm000b4hle4o2fwrvs
cmrknupnu028x4hlem0i1l4n8	ET1620I	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:00.81	2026-07-14 13:02:00.81	cmrknujx800074hlexsapxr4z
cmrknupo2028z4hleqg1ba7qa	X540U	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:00.818	2026-07-14 13:02:00.818	cmrknujxm000b4hle4o2fwrvs
cmrknupq702914hlek53f6kvi	PCG-51111W	cmrknujyl000l4hlezisknz7b	2026-07-14 13:02:00.826	2026-07-14 13:02:00.826	cmrknujxm000b4hle4o2fwrvs
cmrknupqv02934hle3jvi0wb3	UX32L	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:00.919	2026-07-14 13:02:00.919	cmrknujxm000b4hle4o2fwrvs
cmrknupr202954hle578jlm1s	SAF15NB1GL	cmrknujyl000l4hlezisknz7b	2026-07-14 13:02:00.927	2026-07-14 13:02:00.927	cmrknujxm000b4hle4o2fwrvs
cmrknupr702974hlet25muuu4	FX553V	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:00.931	2026-07-14 13:02:00.931	cmrknujxm000b4hle4o2fwrvs
cmrknuprb02994hleqq350dzl	G50-70	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:02:00.936	2026-07-14 13:02:00.936	cmrknujxm000b4hle4o2fwrvs
cmrknuprg029b4hlelz9vr619	ASPIRE ONE	cmrknuk0500114hleha2g5pf3	2026-07-14 13:02:00.94	2026-07-14 13:02:00.94	cmrknujxm000b4hle4o2fwrvs
cmrknuprl029d4hle1rhx3ee7	MI 8SE	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:00.945	2026-07-14 13:02:00.945	cmrkb3cy40000y9h6lftwhcie
cmrknuprt029f4hleiyt8c0jx	Y600-U20	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:00.953	2026-07-14 13:02:00.953	cmrkb3cy40000y9h6lftwhcie
cmrknupry029h4hlei1rgki4n	A1398	cmrknujzo000w4hlesj7fng18	2026-07-14 13:02:00.959	2026-07-14 13:02:00.959	cmrknujxm000b4hle4o2fwrvs
cmrknups2029j4hlexf621f9b	CHE1-L04	cmrknujyo000m4hlecl948w9e	2026-07-14 13:02:00.963	2026-07-14 13:02:00.963	cmrkb3cy40000y9h6lftwhcie
cmrknups5029l4hlew5eymd1s	PROBOOK 4330S	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:02:00.966	2026-07-14 13:02:00.966	cmrknujxm000b4hle4o2fwrvs
cmrknups9029n4hlejm6ufxd8	200G422	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:02:00.969	2026-07-14 13:02:00.969	cmrknujx800074hlexsapxr4z
cmrknupsd029p4hle6aso9nqa	SM_A750GN	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:00.973	2026-07-14 13:02:00.973	cmrkb3cy40000y9h6lftwhcie
cmrknupsg029r4hlejalbiaf4	G62-112EE	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:02:00.976	2026-07-14 13:02:00.976	cmrknujxm000b4hle4o2fwrvs
cmrknupsj029t4hlej0crw8ey	FX516P	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:00.98	2026-07-14 13:02:00.98	cmrknujxm000b4hle4o2fwrvs
cmrknupsn029v4hlefmgynr0b	POCO X2	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:00.983	2026-07-14 13:02:00.983	cmrkb3cy40000y9h6lftwhcie
cmrknupsr029x4hleie0k6126	R528E	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:00.987	2026-07-14 13:02:00.987	cmrknujxm000b4hle4o2fwrvs
cmrknupsu029z4hleohzpj6x7	MAR-LX1A	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:00.99	2026-07-14 13:02:00.99	cmrkb3cy40000y9h6lftwhcie
cmrknupsx02a14hleoh7cgeta	MAR-LX1A	cmrknujyo000m4hlecl948w9e	2026-07-14 13:02:00.993	2026-07-14 13:02:00.993	cmrkb3cy40000y9h6lftwhcie
cmrknupt002a34hlenfrqsytc	ELE-L09	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:00.996	2026-07-14 13:02:00.996	cmrkb3cy40000y9h6lftwhcie
cmrknupt202a54hle1ig4jzib	G500S	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:02:00.999	2026-07-14 13:02:00.999	cmrknujxm000b4hle4o2fwrvs
cmrknupt502a74hlet5e6as3c	ZC554KL	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:01.002	2026-07-14 13:02:01.002	cmrkb3cy40000y9h6lftwhcie
cmrknupt902a94hlexwxr5hel	COMPAQ 1000	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:02:01.005	2026-07-14 13:02:01.005	cmrknujxm000b4hle4o2fwrvs
cmrknuptc02ab4hleh970imsg	PCG-5S1L	cmrknujyl000l4hlezisknz7b	2026-07-14 13:02:01.009	2026-07-14 13:02:01.009	cmrknujxm000b4hle4o2fwrvs
cmrknuptf02ad4hleipyjkh80	FX506LU	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:01.012	2026-07-14 13:02:01.012	cmrknujxm000b4hle4o2fwrvs
cmrknupti02af4hle5imn5a5p	HRY_LX1	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:01.015	2026-07-14 13:02:01.015	cmrkb3cy40000y9h6lftwhcie
cmrknuptm02ah4hlenpzw0ckw	PCG-61312W	cmrknujyl000l4hlezisknz7b	2026-07-14 13:02:01.018	2026-07-14 13:02:01.018	cmrknujxm000b4hle4o2fwrvs
cmrknuptq02aj4hlecxso3pn4	T100T	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:01.022	2026-07-14 13:02:01.022	cmrknujxm000b4hle4o2fwrvs
cmrknuptu02al4hleu9zp8z2n	GEAR S3	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:01.026	2026-07-14 13:02:01.026	cmrknujwz00044hle5lxikvcu
cmrknuptz02an4hlepjv5u5jb	SM-G996B	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:01.031	2026-07-14 13:02:01.031	cmrkb3cy40000y9h6lftwhcie
cmrknupu402ap4hlepbwo6y3i	R565E	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:01.036	2026-07-14 13:02:01.036	cmrknujxm000b4hle4o2fwrvs
cmrknupua02ar4hlet7swwyk2	A2101	cmrknujzo000w4hlesj7fng18	2026-07-14 13:02:01.042	2026-07-14 13:02:01.042	cmrkb3cy40000y9h6lftwhcie
cmrknupug02at4hle7gnh3fcb	BBC100-1	cmrknujyi000k4hlex5dukjd6	2026-07-14 13:02:01.049	2026-07-14 13:02:01.049	cmrkb3cy40000y9h6lftwhcie
cmrknupun02av4hlefjkgeubg	TP00005A	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:02:01.055	2026-07-14 13:02:01.055	cmrknujxm000b4hle4o2fwrvs
cmrknuput02ax4hled6p518ek	AGS-L09	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:01.061	2026-07-14 13:02:01.061	cmrkb3cyo0001y9h6bozaifdg
cmrknupuz02az4hlefghikzhs	A42J	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:01.067	2026-07-14 13:02:01.067	cmrkb3cy40000y9h6lftwhcie
cmrknupv502b14hleg139hiqv	YB1-X91F	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:02:01.073	2026-07-14 13:02:01.073	cmrknujxm000b4hle4o2fwrvs
cmrknupvb02b34hlep2stb35b	G56JK	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:01.08	2026-07-14 13:02:01.08	cmrknujxm000b4hle4o2fwrvs
cmrknupvh02b54hle0vn5e9jk	Z 531KL	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:01.086	2026-07-14 13:02:01.086	cmrkb3cyo0001y9h6bozaifdg
cmrknupvo02b74hlej2ivgz7t	2PS6200	cmrknujzy000z4hlef0vui8me	2026-07-14 13:02:01.092	2026-07-14 13:02:01.092	cmrkb3cy40000y9h6lftwhcie
cmrknupvu02b94hleowdvucq5	X55VD	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:01.099	2026-07-14 13:02:01.099	cmrknujxm000b4hle4o2fwrvs
cmrknupw002bb4hles6s8j1a0	X550Z	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:01.105	2026-07-14 13:02:01.105	cmrknujxm000b4hle4o2fwrvs
cmrknupw602bd4hle6ye9k49u	ELS-NX9	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:01.111	2026-07-14 13:02:01.111	cmrkb3cy40000y9h6lftwhcie
cmrknupwc02bf4hlezronmzhc	FX570U	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:01.117	2026-07-14 13:02:01.117	cmrknujxm000b4hle4o2fwrvs
cmrknupwj02bh4hleo8uhsd8k	V241E (آل این وان)	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:01.123	2026-07-14 13:02:01.123	cmrknujx800074hlexsapxr4z
cmrknupww02bj4hleoo9gk0hd	GT-7500	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:01.136	2026-07-14 13:02:01.136	cmrkb3cyo0001y9h6bozaifdg
cmrknupx302bl4hlem04p3su0	T355	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:01.143	2026-07-14 13:02:01.143	cmrkb3cyo0001y9h6bozaifdg
cmrknupxb02bn4hle8d44ob4x	K00E	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:01.151	2026-07-14 13:02:01.151	cmrkb3cyo0001y9h6bozaifdg
cmrknupxi02bp4hlepwntwpw1	AMAZFIT PACE	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:01.159	2026-07-14 13:02:01.159	cmrknujwz00044hle5lxikvcu
cmrknupxp02br4hlecuq1xfjv	A1612	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:01.165	2026-07-14 13:02:01.165	cmrknujwz00044hle5lxikvcu
cmrknupxw02bt4hleap21in4n	FX516P (موبایل)	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:01.172	2026-07-14 13:02:01.172	cmrkb3cy40000y9h6lftwhcie
cmrknupy702bv4hleuqaj0eg6	15-DA1023NIA	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:02:01.183	2026-07-14 13:02:01.183	cmrknujxm000b4hle4o2fwrvs
cmrknupyf02bx4hle6dwgf5io	Y511-U30	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:01.191	2026-07-14 13:02:01.191	cmrkb3cy40000y9h6lftwhcie
cmrknupym02bz4hlektve56te	13T-AC000	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:02:01.198	2026-07-14 13:02:01.198	cmrknujxm000b4hle4o2fwrvs
cmrknupyt02c14hleb8rihbs0	INSPIRON 1545	cmrknujzd000t4hle1ujh33no	2026-07-14 13:02:01.205	2026-07-14 13:02:01.205	cmrknujxm000b4hle4o2fwrvs
cmrknupyz02c34hlegtnxuagt	RADMI PAD	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:01.212	2026-07-14 13:02:01.212	cmrkb3cyo0001y9h6bozaifdg
cmrknupz502c54hleloeicq7c	L55M-5S	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:01.217	2026-07-14 13:02:01.217	cmrknujy0000g4hleg9xefyth
cmrknupzb02c74hlenfp7yfzg	LYA-AL00	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:01.224	2026-07-14 13:02:01.224	cmrkb3cy40000y9h6lftwhcie
cmrknupzi02c94hlext82bx54	NP900X3C	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:01.23	2026-07-14 13:02:01.23	cmrknujxm000b4hle4o2fwrvs
cmrknupzo02cb4hlelyyym6oj	AMAZFIT GTR3	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:01.236	2026-07-14 13:02:01.236	cmrknujwz00044hle5lxikvcu
cmrknupzu02cd4hlesttibbts	SM-G998B	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:01.243	2026-07-14 13:02:01.243	cmrkb3cy40000y9h6lftwhcie
cmrknuq0102cf4hleswtzzfzf	SM-A715F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:01.249	2026-07-14 13:02:01.249	cmrkb3cy40000y9h6lftwhcie
cmrknuq0802ch4hlep5hqkanp	LATITUDE 7480	cmrknujzd000t4hle1ujh33no	2026-07-14 13:02:01.256	2026-07-14 13:02:01.256	cmrknujxm000b4hle4o2fwrvs
cmrknuq0f02cj4hleruxfl9t2	MI 11I 5G	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:01.263	2026-07-14 13:02:01.263	cmrkb3cy40000y9h6lftwhcie
cmrknuq0l02cl4hlemffw6m84	INSPIRON 1501	cmrknujzd000t4hle1ujh33no	2026-07-14 13:02:01.269	2026-07-14 13:02:01.269	cmrknujxm000b4hle4o2fwrvs
cmrknuq0s02cn4hleaunyv66b	PCG_61611L	cmrknujyl000l4hlezisknz7b	2026-07-14 13:02:01.276	2026-07-14 13:02:01.276	cmrknujxm000b4hle4o2fwrvs
cmrknuq0y02cp4hle4gli90uv	AMAZFIT STRATOS	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:01.282	2026-07-14 13:02:01.282	cmrknujwz00044hle5lxikvcu
cmrknuq1502cr4hleqvnrdlrk	SM-G900F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:01.29	2026-07-14 13:02:01.29	cmrkb3cy40000y9h6lftwhcie
cmrknuq1d02ct4hlehe90cd92	LATITUDE 5290	cmrknujzd000t4hle1ujh33no	2026-07-14 13:02:01.297	2026-07-14 13:02:01.297	cmrkb3cyo0001y9h6bozaifdg
cmrknuq1k02cv4hlem8hv3lst	MI 10 5G	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:01.305	2026-07-14 13:02:01.305	cmrkb3cy40000y9h6lftwhcie
cmrknuq1s02cx4hle5nvh8q8s	AGS2-L03	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:01.312	2026-07-14 13:02:01.312	cmrkb3cyo0001y9h6bozaifdg
cmrknuq1y02cz4hleykbkmvzb	OPGL-200	cmrknujzy000z4hlef0vui8me	2026-07-14 13:02:01.318	2026-07-14 13:02:01.318	cmrkb3cy40000y9h6lftwhcie
cmrknuq2502d14hleaehd6vdg	GALAXY WATCH 4	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:01.325	2026-07-14 13:02:01.325	cmrknujwz00044hle5lxikvcu
cmrknuq2b02d34hleo1oq0vds	SM-A725F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:01.332	2026-07-14 13:02:01.332	cmrkb3cy40000y9h6lftwhcie
cmrknuq2j02d54hle1s1bvbuv	INE-LX1	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:01.34	2026-07-14 13:02:01.34	cmrkb3cy40000y9h6lftwhcie
cmrknuq2r02d74hle80fe2yxh	Z01FD	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:01.347	2026-07-14 13:02:01.347	cmrkb3cy40000y9h6lftwhcie
cmrknuq2y02d94hle4zg3t0gg	PAD 6	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:01.354	2026-07-14 13:02:01.354	cmrkb3cyo0001y9h6bozaifdg
cmrknuq3402db4hlesku9kr6z	BDZ-WDH9A	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:01.36	2026-07-14 13:02:01.36	cmrknujxm000b4hle4o2fwrvs
cmrknuq3d02dd4hlesdxwqafp	MI 10T PRO	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:01.369	2026-07-14 13:02:01.369	cmrkb3cy40000y9h6lftwhcie
cmrknuq3m02df4hle2ipax6f4	FOLIO 9480M	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:02:01.378	2026-07-14 13:02:01.378	cmrknujxm000b4hle4o2fwrvs
cmrknuq3u02dh4hlej7l39ypp	GEAR S2	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:01.386	2026-07-14 13:02:01.386	cmrknujwz00044hle5lxikvcu
cmrknuq4202dj4hleqjw0269p	NP 300V5A	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:01.394	2026-07-14 13:02:01.394	cmrknujxm000b4hle4o2fwrvs
cmrknuq4902dl4hlerempm3gm	N56V8	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:01.401	2026-07-14 13:02:01.401	cmrknujxm000b4hle4o2fwrvs
cmrknuq4g02dn4hlee6ndewrg	ASPIRE 5755	cmrknuk0500114hleha2g5pf3	2026-07-14 13:02:01.408	2026-07-14 13:02:01.408	cmrknujxm000b4hle4o2fwrvs
cmrknuq4m02dp4hlekxwaw86s	SM-N900	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:01.414	2026-07-14 13:02:01.414	cmrkb3cy40000y9h6lftwhcie
cmrknuq4t02dr4hle28ki19uy	T-300	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:01.421	2026-07-14 13:02:01.421	cmrkb3cy40000y9h6lftwhcie
cmrknuq5002dt4hleg386gm6x	MACH-W29	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:01.429	2026-07-14 13:02:01.429	cmrknujxm000b4hle4o2fwrvs
cmrknuq5702dv4hle918744ss	SM-T735	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:01.435	2026-07-14 13:02:01.435	cmrkb3cyo0001y9h6bozaifdg
cmrknuq5e02dx4hle19l03og8	SM-T505	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:01.442	2026-07-14 13:02:01.442	cmrkb3cyo0001y9h6bozaifdg
cmrknuq5l02dz4hlewmbpje65	LLD-L21	cmrknujyo000m4hlecl948w9e	2026-07-14 13:02:01.449	2026-07-14 13:02:01.449	cmrkb3cy40000y9h6lftwhcie
cmrknuq5t02e14hleghvcjlip	G630-U10	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:01.457	2026-07-14 13:02:01.457	cmrkb3cy40000y9h6lftwhcie
cmrknuq5z02e34hlejp111l5i	POCO X3 GT	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:01.463	2026-07-14 13:02:01.463	cmrkb3cy40000y9h6lftwhcie
cmrknuq6602e54hle3kvjcu23	LON_L29	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:01.471	2026-07-14 13:02:01.471	cmrkb3cy40000y9h6lftwhcie
cmrknuq6e02e74hleqvsya5dv	A1567	cmrknujzo000w4hlesj7fng18	2026-07-14 13:02:01.478	2026-07-14 13:02:01.478	cmrkb3cyo0001y9h6bozaifdg
cmrknuq6k02e94hlevcn84ozx	SM-J600F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:01.484	2026-07-14 13:02:01.484	cmrkb3cy40000y9h6lftwhcie
cmrknuq6r02eb4hleld3gwdio	SM-T725	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:01.491	2026-07-14 13:02:01.491	cmrkb3cyo0001y9h6bozaifdg
cmrknuq6y02ed4hle1capcrgr	NXT-L29	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:01.498	2026-07-14 13:02:01.498	cmrkb3cy40000y9h6lftwhcie
cmrknuq7502ef4hleu61bxhjq	15_BC299NIA	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:02:01.505	2026-07-14 13:02:01.505	cmrknujxm000b4hle4o2fwrvs
cmrknuq7b02eh4hleghi6m47r	PCG-61A11W	cmrknujyl000l4hlezisknz7b	2026-07-14 13:02:01.512	2026-07-14 13:02:01.512	cmrknujxm000b4hle4o2fwrvs
cmrknuq7i02ej4hlekzpunhl2	G512L	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:01.518	2026-07-14 13:02:01.518	cmrknujxm000b4hle4o2fwrvs
cmrknuq7p02el4hleucizbzon	GT-P7300	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:01.525	2026-07-14 13:02:01.525	cmrkb3cy40000y9h6lftwhcie
cmrknuq7w02en4hler4f4n5mu	TB-M8 8505X	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:02:01.532	2026-07-14 13:02:01.532	cmrkb3cyo0001y9h6bozaifdg
cmrknuq8302ep4hleyfn1ryek	13M-BD0023DX	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:02:01.539	2026-07-14 13:02:01.539	cmrknujxm000b4hle4o2fwrvs
cmrknuq8902er4hlel8fspp6i	SERISE 5	cmrknujzo000w4hlesj7fng18	2026-07-14 13:02:01.546	2026-07-14 13:02:01.546	cmrknujwz00044hle5lxikvcu
cmrknuq8g02et4hlepk21lvkf	SERISE5	cmrknujzo000w4hlesj7fng18	2026-07-14 13:02:01.553	2026-07-14 13:02:01.553	cmrknujwz00044hle5lxikvcu
cmrknuq8n02ev4hletg51bxqw	MI 5S	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:01.56	2026-07-14 13:02:01.56	cmrkb3cy40000y9h6lftwhcie
cmrknuq8u02ex4hler59fddqq	Z2151	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:02:01.566	2026-07-14 13:02:01.566	cmrkb3cy40000y9h6lftwhcie
cmrknuq9102ez4hleulyfajan	SERIES 3	cmrknujzo000w4hlesj7fng18	2026-07-14 13:02:01.573	2026-07-14 13:02:01.573	cmrknujwz00044hle5lxikvcu
cmrknuq9702f14hles05ixyro	A 1524	cmrknujzo000w4hlesj7fng18	2026-07-14 13:02:01.579	2026-07-14 13:02:01.579	cmrkb3cy40000y9h6lftwhcie
cmrknuq9e02f34hlelayavsrd	X018D	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:01.586	2026-07-14 13:02:01.586	cmrkb3cy40000y9h6lftwhcie
cmrknuq9m02f54hle2ei2vep1	ASPIRE V5-591	cmrknuk0500114hleha2g5pf3	2026-07-14 13:02:01.594	2026-07-14 13:02:01.594	cmrknujxm000b4hle4o2fwrvs
cmrknuq9u02f74hle329ujxnm	REDMI 12C	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:01.602	2026-07-14 13:02:01.602	cmrkb3cy40000y9h6lftwhcie
cmrknuqa102f94hle4ck8pk40	AUM-L29	cmrknujyo000m4hlecl948w9e	2026-07-14 13:02:01.609	2026-07-14 13:02:01.609	cmrkb3cy40000y9h6lftwhcie
cmrknuqa802fb4hlecn2zu5rr	REDMI NOTE 12 4G	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:01.616	2026-07-14 13:02:01.616	cmrkb3cy40000y9h6lftwhcie
cmrknuqaf02fd4hle6mf64lvr	LATITUDE10-ST2	cmrknujzd000t4hle1ujh33no	2026-07-14 13:02:01.623	2026-07-14 13:02:01.623	cmrkb3cyo0001y9h6bozaifdg
cmrknuqal02ff4hlebm79gasq	A2221	cmrknujzo000w4hlesj7fng18	2026-07-14 13:02:01.629	2026-07-14 13:02:01.629	cmrkb3cy40000y9h6lftwhcie
cmrknuqar02fh4hle0eihln6m	FLEX 2-15	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:02:01.636	2026-07-14 13:02:01.636	cmrknujxm000b4hle4o2fwrvs
cmrknuqay02fj4hles9r5c576	SM-T510	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:01.643	2026-07-14 13:02:01.643	cmrkb3cyo0001y9h6bozaifdg
cmrknuqb502fl4hle2oqe1fgq	V3_DUG	cmrknujzy000z4hlef0vui8me	2026-07-14 13:02:01.649	2026-07-14 13:02:01.649	cmrkb3cy40000y9h6lftwhcie
cmrknuqbc02fn4hlelbq9m02o	E550	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:02:01.656	2026-07-14 13:02:01.656	cmrknujxm000b4hle4o2fwrvs
cmrknuqbi02fp4hle9pm84l99	A55ML-DTUL	cmrknujzy000z4hlef0vui8me	2026-07-14 13:02:01.663	2026-07-14 13:02:01.663	cmrkb3cy40000y9h6lftwhcie
cmrknuqbp02fr4hlesckt9kyk	SM-T700X	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:01.669	2026-07-14 13:02:01.669	cmrkb3cy40000y9h6lftwhcie
cmrknuqbw02ft4hleoz7tzs3j	BLACK SHARK 2 PRO	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:01.676	2026-07-14 13:02:01.676	cmrkb3cy40000y9h6lftwhcie
cmrknuqc202fv4hlew11fid0t	HMA-L29	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:01.682	2026-07-14 13:02:01.682	cmrkb3cy40000y9h6lftwhcie
cmrknuqc902fx4hleuz7dv9ab	13M-BD1033DX	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:02:01.689	2026-07-14 13:02:01.689	cmrknujxm000b4hle4o2fwrvs
cmrknuqcf02fz4hlev182oszg	G470	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:02:01.695	2026-07-14 13:02:01.695	cmrknujxm000b4hle4o2fwrvs
cmrknuqcl02g14hlejx26zcp2	ASPIRE 5552G	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:01.701	2026-07-14 13:02:01.701	cmrknujxm000b4hle4o2fwrvs
cmrknuqcs02g34hler8pmfp2a	K45VD	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:01.708	2026-07-14 13:02:01.708	cmrknujxm000b4hle4o2fwrvs
cmrknuqcy02g54hlex6rz4rbb	SM-A510FD	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:01.715	2026-07-14 13:02:01.715	cmrkb3cy40000y9h6lftwhcie
cmrknuqd502g74hlew73ftgs4	REDMI NOTE 7 PRO	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:01.721	2026-07-14 13:02:01.721	cmrkb3cy40000y9h6lftwhcie
cmrknuqdb02g94hle2zq36bsn	AX200NGW	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:02:01.728	2026-07-14 13:02:01.728	cmrknujxm000b4hle4o2fwrvs
cmrknuqdi02gb4hle0v8co4ib	SERIES SE	cmrknujzo000w4hlesj7fng18	2026-07-14 13:02:01.734	2026-07-14 13:02:01.734	cmrknujwz00044hle5lxikvcu
cmrknuqdp02gd4hlepn5jz7n2	NMO-L31	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:01.741	2026-07-14 13:02:01.741	cmrkb3cy40000y9h6lftwhcie
cmrknuqdv02gf4hle8etpp6gt	KOB_L09	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:01.747	2026-07-14 13:02:01.747	cmrkb3cyo0001y9h6bozaifdg
cmrknuqe102gh4hle8b8ytz5z	RLO-LO1	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:01.754	2026-07-14 13:02:01.754	cmrkb3cy40000y9h6lftwhcie
cmrknuqe802gj4hleam6xlvq5	ASPIRE  A515-51	cmrknuk0500114hleha2g5pf3	2026-07-14 13:02:01.76	2026-07-14 13:02:01.76	cmrknujxm000b4hle4o2fwrvs
cmrknuqee02gl4hlejwzkxf3q	SERIES 6	cmrknujzo000w4hlesj7fng18	2026-07-14 13:02:01.766	2026-07-14 13:02:01.766	cmrknujwz00044hle5lxikvcu
cmrknuqek02gn4hleayygdxym	VKY-L29	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:01.772	2026-07-14 13:02:01.772	cmrkb3cy40000y9h6lftwhcie
cmrknuqer02gp4hle15m32m4c	DAV-701L	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:01.779	2026-07-14 13:02:01.779	cmrkb3cyo0001y9h6bozaifdg
cmrknuqey02gr4hleiup299dz	ANE-TL00	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:01.786	2026-07-14 13:02:01.786	cmrkb3cy40000y9h6lftwhcie
cmrknuqf502gt4hle44oqa1om	SM-M127F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:01.793	2026-07-14 13:02:01.793	cmrkb3cy40000y9h6lftwhcie
cmrknuqfb02gv4hlek46rop9z	MS-1688	cmrknujz9000s4hleu8mshqu7	2026-07-14 13:02:01.799	2026-07-14 13:02:01.799	cmrknujxm000b4hle4o2fwrvs
cmrknuqfh02gx4hleyn7gomuk	SVD112A1WL	cmrknujyl000l4hlezisknz7b	2026-07-14 13:02:01.805	2026-07-14 13:02:01.805	cmrknujxm000b4hle4o2fwrvs
cmrknuqfo02gz4hlepb5trfxm	MS-1688 (موبایل)	cmrknujz9000s4hleu8mshqu7	2026-07-14 13:02:01.812	2026-07-14 13:02:01.812	cmrkb3cy40000y9h6lftwhcie
cmrknuqfy02h14hledwy1b88i	UX303U	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:01.822	2026-07-14 13:02:01.822	cmrknujxm000b4hle4o2fwrvs
cmrknuqg402h34hleqsj2ao2r	P 008	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:01.829	2026-07-14 13:02:01.829	cmrkb3cyo0001y9h6bozaifdg
cmrknuqgb02h54hle0z9e77x0	MI-A 1	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:01.835	2026-07-14 13:02:01.835	cmrkb3cy40000y9h6lftwhcie
cmrknuqgi02h74hlerqmjwond	GT-N7100	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:01.842	2026-07-14 13:02:01.842	cmrkb3cy40000y9h6lftwhcie
cmrknuqgp02h94hle6pr8eao6	INE-LX1R	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:01.849	2026-07-14 13:02:01.849	cmrkb3cy40000y9h6lftwhcie
cmrknuqgw02hb4hle0qfzbumk	KOB2-L09	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:01.856	2026-07-14 13:02:01.856	cmrkb3cyo0001y9h6bozaifdg
cmrknuqh202hd4hlelrsy76vd	KSA-LX9	cmrknujyo000m4hlecl948w9e	2026-07-14 13:02:01.863	2026-07-14 13:02:01.863	cmrkb3cy40000y9h6lftwhcie
cmrknuqh902hf4hlesssg7rt4	SM-S918B	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:01.869	2026-07-14 13:02:01.869	cmrkb3cy40000y9h6lftwhcie
cmrknuqhg02hh4hleenswuxzn	OPJA100	cmrknujzy000z4hlef0vui8me	2026-07-14 13:02:01.877	2026-07-14 13:02:01.877	cmrkb3cy40000y9h6lftwhcie
cmrknuqhm02hj4hle32dtntr8	GT-19060I	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:01.883	2026-07-14 13:02:01.883	cmrkb3cy40000y9h6lftwhcie
cmrknuqht02hl4hlepbe68m80	TB-8504X	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:02:01.889	2026-07-14 13:02:01.889	cmrkb3cyo0001y9h6bozaifdg
cmrknuqi002hn4hle0f3v27j3	ACTIVE  2	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:01.896	2026-07-14 13:02:01.896	cmrknujwz00044hle5lxikvcu
cmrknuqi602hp4hlehdlkp74h	A1457	cmrknujzo000w4hlesj7fng18	2026-07-14 13:02:01.903	2026-07-14 13:02:01.903	cmrkb3cy40000y9h6lftwhcie
cmrknuqie02hr4hleu3a03ehe	SM-A507FN	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:01.91	2026-07-14 13:02:01.91	cmrkb3cy40000y9h6lftwhcie
cmrknuqik02ht4hle008pccgh	K555L	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:01.916	2026-07-14 13:02:01.916	cmrknujxm000b4hle4o2fwrvs
cmrknuqis02hv4hle964yskd2	GT 3	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:01.924	2026-07-14 13:02:01.924	cmrknujwz00044hle5lxikvcu
cmrknuqj002hx4hletb76c1n7	X550D	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:01.932	2026-07-14 13:02:01.932	cmrknujxm000b4hle4o2fwrvs
cmrknuqj602hz4hlerj9tf5mr	REDMI 7A	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:01.939	2026-07-14 13:02:01.939	cmrkb3cy40000y9h6lftwhcie
cmrknuqjd02i14hleqnfhekrb	12PRO	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:01.946	2026-07-14 13:02:01.946	cmrkb3cy40000y9h6lftwhcie
cmrknuqjk02i34hlehtq7ls4r	AIR	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:01.952	2026-07-14 13:02:01.952	cmrknujxm000b4hle4o2fwrvs
cmrknuqjr02i54hle7oebhi00	SM-N975F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:01.959	2026-07-14 13:02:01.959	cmrkb3cy40000y9h6lftwhcie
cmrknuqjy02i74hleqetpbn42	SENSATION XLX315G	cmrknujzy000z4hlef0vui8me	2026-07-14 13:02:01.966	2026-07-14 13:02:01.966	cmrkb3cy40000y9h6lftwhcie
cmrknuqk502i94hlel4sera02	SM-A606F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:01.973	2026-07-14 13:02:01.973	cmrkb3cy40000y9h6lftwhcie
cmrknuqkb02ib4hleubst15ll	REDMI 5 PLUS	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:01.98	2026-07-14 13:02:01.98	cmrkb3cy40000y9h6lftwhcie
cmrknuqkj02id4hlergjuibjk	SM-P601 (موبایل)	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:01.987	2026-07-14 13:02:01.987	cmrkb3cy40000y9h6lftwhcie
cmrknuqkv02if4hleblayogma	PROBOOK 450	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:02:01.999	2026-07-14 13:02:01.999	cmrknujxm000b4hle4o2fwrvs
cmrknuql202ih4hles63rig56	UX434F	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:02.006	2026-07-14 13:02:02.006	cmrknujxm000b4hle4o2fwrvs
cmrknuql802ij4hlez86derv7	SM-G781B	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:02.012	2026-07-14 13:02:02.012	cmrkb3cy40000y9h6lftwhcie
cmrknuqlf02il4hleobcygeb7	S20 FE5G	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:02.019	2026-07-14 13:02:02.019	cmrkb3cy40000y9h6lftwhcie
cmrknuqll02in4hle0dajecbk	G3	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:02.026	2026-07-14 13:02:02.026	cmrknujwz00044hle5lxikvcu
cmrknuqlr02ip4hle97lamw91	SM-G991B	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:02.032	2026-07-14 13:02:02.032	cmrkb3cy40000y9h6lftwhcie
cmrknuqly02ir4hle8cbqndsc	PAVILION DV5	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:02:02.039	2026-07-14 13:02:02.039	cmrknujxm000b4hle4o2fwrvs
cmrknuqm502it4hleszxy0ve9	MI NOTE	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:02.045	2026-07-14 13:02:02.045	cmrkb3cy40000y9h6lftwhcie
cmrknuqmb02iv4hlef6q3dxbu	A 6421	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:02.051	2026-07-14 13:02:02.051	cmrknujx800074hlexsapxr4z
cmrknuqmi02ix4hle5gnlpf3u	K451L	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:02.058	2026-07-14 13:02:02.058	cmrknujxm000b4hle4o2fwrvs
cmrknuqmo02iz4hlekg1g7mhf	ELITE BOOK 2540P	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:02:02.065	2026-07-14 13:02:02.065	cmrknujxm000b4hle4o2fwrvs
cmrknuqmv02j14hle4ivki0aq	REDMI 6A	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:02.071	2026-07-14 13:02:02.071	cmrkb3cy40000y9h6lftwhcie
cmrknuqn102j34hlendox0txu	WKG-LX9	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:02.077	2026-07-14 13:02:02.077	cmrkb3cy40000y9h6lftwhcie
cmrknuqn702j54hleae4neh7c	ASPIRE R  14	cmrknuk0500114hleha2g5pf3	2026-07-14 13:02:02.083	2026-07-14 13:02:02.083	cmrknujxm000b4hle4o2fwrvs
cmrknuqne02j74hle0lo8sqw4	TAB 2 A10-70L	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:02:02.09	2026-07-14 13:02:02.09	cmrkb3cyo0001y9h6bozaifdg
cmrknuqnk02j94hleio67n7o9	TAB 2 A10-70L (موبایل)	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:02:02.096	2026-07-14 13:02:02.096	cmrkb3cy40000y9h6lftwhcie
cmrknuqnu02jb4hlet1ejkr3d	GL502V	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:02.107	2026-07-14 13:02:02.107	cmrknujxm000b4hle4o2fwrvs
cmrknuqo002jd4hleejdq41p2	SM-N910H	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:02.113	2026-07-14 13:02:02.113	cmrkb3cy40000y9h6lftwhcie
cmrknuqo602jf4hledlrxpho0	THINKPAD 10	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:02.119	2026-07-14 13:02:02.119	cmrkb3cyo0001y9h6bozaifdg
cmrknuqod02jh4hlefwq3ff8j	CLT-L29	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:02.125	2026-07-14 13:02:02.125	cmrkb3cy40000y9h6lftwhcie
cmrknuqoj02jj4hle1hcz8q7t	AMN-LX9	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:02.131	2026-07-14 13:02:02.131	cmrkb3cy40000y9h6lftwhcie
cmrknuqoq02jl4hleitxjkba7	P210NE	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:02:02.138	2026-07-14 13:02:02.138	cmrkb3cy40000y9h6lftwhcie
cmrknuqow02jn4hleb3r3m7zg	SM-G973F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:02.145	2026-07-14 13:02:02.145	cmrkb3cy40000y9h6lftwhcie
cmrknuqp202jp4hlektbu5hn0	N580G	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:02.151	2026-07-14 13:02:02.151	cmrknujxm000b4hle4o2fwrvs
cmrknuqp902jr4hlej33uq7e6	MI 9 SE	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:02.157	2026-07-14 13:02:02.157	cmrkb3cy40000y9h6lftwhcie
cmrknuqpf02jt4hlec99pr8fr	ASPIRE A715-74G	cmrknuk0500114hleha2g5pf3	2026-07-14 13:02:02.163	2026-07-14 13:02:02.163	cmrknujxm000b4hle4o2fwrvs
cmrknuqpl02jv4hledbc9i7sx	P024	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:02.169	2026-07-14 13:02:02.169	cmrkb3cyo0001y9h6bozaifdg
cmrknuqps02jx4hle1yozi779	S6000	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:02:02.176	2026-07-14 13:02:02.176	cmrkb3cyo0001y9h6bozaifdg
cmrknuqpy02jz4hlehonq9twa	JAT-L29	cmrknujyo000m4hlecl948w9e	2026-07-14 13:02:02.183	2026-07-14 13:02:02.183	cmrkb3cy40000y9h6lftwhcie
cmrknuqq502k14hlekax8wiax	SM-A022F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:02.19	2026-07-14 13:02:02.19	cmrkb3cy40000y9h6lftwhcie
cmrknuqqb02k34hlezutaaaxb	TP203N	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:02.196	2026-07-14 13:02:02.196	cmrknujxm000b4hle4o2fwrvs
cmrknuqqi02k54hle8gkka5od	BND-L21	cmrknujyo000m4hlecl948w9e	2026-07-14 13:02:02.202	2026-07-14 13:02:02.202	cmrkb3cy40000y9h6lftwhcie
cmrknuqqo02k74hletbgtyqgm	M2004J19G	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:02.209	2026-07-14 13:02:02.209	cmrkb3cy40000y9h6lftwhcie
cmrknuqqv02k94hle4d315eki	AGS3-L09	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:02.215	2026-07-14 13:02:02.215	cmrkb3cyo0001y9h6bozaifdg
cmrknuqr102kb4hles8foi0ai	ASPIRE 5552	cmrknuk0500114hleha2g5pf3	2026-07-14 13:02:02.222	2026-07-14 13:02:02.222	cmrknujxm000b4hle4o2fwrvs
cmrknuqr802kd4hle793ssnq5	SM-F711B	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:02.228	2026-07-14 13:02:02.228	cmrkb3cy40000y9h6lftwhcie
cmrknuqre02kf4hlefzxppos4	REDMI NOTE 11 PRO 4G	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:02.234	2026-07-14 13:02:02.234	cmrkb3cy40000y9h6lftwhcie
cmrknuqrk02kh4hlefdq08wmx	INE-LX2	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:02.241	2026-07-14 13:02:02.241	cmrkb3cy40000y9h6lftwhcie
cmrknuqrq02kj4hlekircokz6	UX535L	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:02.247	2026-07-14 13:02:02.247	cmrknujxm000b4hle4o2fwrvs
cmrknuqrx02kl4hlennrnsfce	GEM-701L (تبلت)	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:02.253	2026-07-14 13:02:02.253	cmrkb3cyo0001y9h6bozaifdg
cmrknuqs802kn4hlem47bnnwv	ACTIVE 2	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:02.264	2026-07-14 13:02:02.264	cmrknujwz00044hle5lxikvcu
cmrknuqsf02kp4hleyi4ysyjm	VOSTRO 3300	cmrknuk0500114hleha2g5pf3	2026-07-14 13:02:02.272	2026-07-14 13:02:02.272	cmrknujxm000b4hle4o2fwrvs
cmrknuqsm02kr4hlebdxj6pyo	X54H	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:02.279	2026-07-14 13:02:02.279	cmrknujxm000b4hle4o2fwrvs
cmrknuqst02kt4hleqcmfohm9	black shark 4 pro	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:02.285	2026-07-14 13:02:02.285	cmrkb3cy40000y9h6lftwhcie
cmrknuqt002kv4hleucet4r08	ART-L29	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:02.292	2026-07-14 13:02:02.292	cmrkb3cy40000y9h6lftwhcie
cmrknuqt602kx4hlenutaj2k1	SM-N920CD	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:02.298	2026-07-14 13:02:02.298	cmrkb3cy40000y9h6lftwhcie
cmrknuqtd02kz4hleahxo47ro	BLACK SHARK2	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:02.305	2026-07-14 13:02:02.305	cmrkb3cy40000y9h6lftwhcie
cmrknuqtj02l14hlelo607u8u	BLACK SHARP 2	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:02.312	2026-07-14 13:02:02.312	cmrkb3cy40000y9h6lftwhcie
cmrknuqtq02l34hlejuvzok3v	HOL-U19	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:02.318	2026-07-14 13:02:02.318	cmrkb3cy40000y9h6lftwhcie
cmrknuqtx02l54hlenlqm3tzf	MI NOTE 10 PRO	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:02.325	2026-07-14 13:02:02.325	cmrkb3cy40000y9h6lftwhcie
cmrknuqu302l74hle9nadgfus	GL553V	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:02.331	2026-07-14 13:02:02.331	cmrknujxm000b4hle4o2fwrvs
cmrknuqua02l94hleey5obpt7	P87F	cmrknuk22001k4hlewvssmg0i	2026-07-14 13:02:02.338	2026-07-14 13:02:02.338	cmrknujxm000b4hle4o2fwrvs
cmrknuqug02lb4hle0xol5ey8	INSPIRON N5040	cmrknujzd000t4hle1ujh33no	2026-07-14 13:02:02.345	2026-07-14 13:02:02.345	cmrknujxm000b4hle4o2fwrvs
cmrknuqun02ld4hleepm1g6yn	OP6B900	cmrknujzy000z4hlef0vui8me	2026-07-14 13:02:02.351	2026-07-14 13:02:02.351	cmrkb3cy40000y9h6lftwhcie
cmrknuquu02lf4hlee5hylluj	SM-N986B	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:02.358	2026-07-14 13:02:02.358	cmrkb3cy40000y9h6lftwhcie
cmrknuqv102lh4hle6ubud4sz	JDN-L09	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:02.365	2026-07-14 13:02:02.365	cmrkb3cyo0001y9h6bozaifdg
cmrknuqv802lj4hlems0o8n5j	MI 11	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:02.372	2026-07-14 13:02:02.372	cmrkb3cy40000y9h6lftwhcie
cmrknuqve02ll4hle3mh5w2wl	ASPIRE 5749	cmrknuk0500114hleha2g5pf3	2026-07-14 13:02:02.378	2026-07-14 13:02:02.378	cmrknujxm000b4hle4o2fwrvs
cmrknuqvl02ln4hlen1xpqsjk	FIGTL10	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:02.385	2026-07-14 13:02:02.385	cmrkb3cy40000y9h6lftwhcie
cmrknuqvs02lp4hle2rax100t	JSN-L22	cmrknujyo000m4hlecl948w9e	2026-07-14 13:02:02.392	2026-07-14 13:02:02.392	cmrkb3cy40000y9h6lftwhcie
cmrknuqvy02lr4hlephishitk	REDMI NOTE 4	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:02.398	2026-07-14 13:02:02.398	cmrkb3cy40000y9h6lftwhcie
cmrknuqw502lt4hle8do1pesr	PCG-81111W	cmrknujyl000l4hlezisknz7b	2026-07-14 13:02:02.405	2026-07-14 13:02:02.405	cmrknujxm000b4hle4o2fwrvs
cmrknuqwc02lv4hleccl8amzg	T100H	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:02.412	2026-07-14 13:02:02.412	cmrknujxm000b4hle4o2fwrvs
cmrknuqwj02lx4hleevalz332	POCO X4 GT 5G	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:02.419	2026-07-14 13:02:02.419	cmrkb3cy40000y9h6lftwhcie
cmrknuqwq02lz4hlelwsbcm2w	X555L	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:02.427	2026-07-14 13:02:02.427	cmrkb3cy40000y9h6lftwhcie
cmrknuqwx02m14hleooag8got	P10	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:02.433	2026-07-14 13:02:02.433	cmrkb3cy40000y9h6lftwhcie
cmrknuqx402m34hleynlr1hro	FDR-A01L	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:02.44	2026-07-14 13:02:02.44	cmrkb3cyo0001y9h6bozaifdg
cmrknuqxb02m54hlecy182wt3	2PZF100	cmrknujzy000z4hlef0vui8me	2026-07-14 13:02:02.447	2026-07-14 13:02:02.447	cmrkb3cy40000y9h6lftwhcie
cmrknuqxh02m74hle4cthofrf	X551M	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:02.453	2026-07-14 13:02:02.453	cmrknujxm000b4hle4o2fwrvs
cmrknuqxp02m94hleilb6a2jt	SVF15AA1QL	cmrknujyl000l4hlezisknz7b	2026-07-14 13:02:02.461	2026-07-14 13:02:02.461	cmrknujxm000b4hle4o2fwrvs
cmrknuqxv02mb4hlen001a4fl	FX506L	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:02.467	2026-07-14 13:02:02.467	cmrknujxm000b4hle4o2fwrvs
cmrknuqy202md4hle6oufk2k2	SM-N915F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:02.475	2026-07-14 13:02:02.475	cmrkb3cy40000y9h6lftwhcie
cmrknuqy902mf4hlembjx6s4g	R1502Z	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:02.481	2026-07-14 13:02:02.481	cmrknujxm000b4hle4o2fwrvs
cmrknuqyg02mh4hle0fnemoym	PPA-LX2	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:02.488	2026-07-14 13:02:02.488	cmrkb3cy40000y9h6lftwhcie
cmrknuqyn02mj4hles2051c0e	F102B	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:02.495	2026-07-14 13:02:02.495	cmrknujxm000b4hle4o2fwrvs
cmrknuqyu02ml4hle1kcf9jhf	A1865	cmrknujzo000w4hlesj7fng18	2026-07-14 13:02:02.502	2026-07-14 13:02:02.502	cmrkb3cy40000y9h6lftwhcie
cmrknuqz102mn4hledmtfvzeq	MI 11I	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:02.509	2026-07-14 13:02:02.509	cmrkb3cy40000y9h6lftwhcie
cmrknuqz802mp4hlevfq7v26z	hg8245c	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:02.516	2026-07-14 13:02:02.516	cmrknujxr000d4hlevkgzk27o
cmrknuqzf02mr4hlegfw1ce7y	PCG-6X1L	cmrknujyl000l4hlezisknz7b	2026-07-14 13:02:02.523	2026-07-14 13:02:02.523	cmrknujxm000b4hle4o2fwrvs
cmrknuqzl02mt4hle0n1r3rkr	PCG-81214N	cmrknujyl000l4hlezisknz7b	2026-07-14 13:02:02.53	2026-07-14 13:02:02.53	cmrknujxm000b4hle4o2fwrvs
cmrknuqzt02mv4hle8vctv64h	AGS2-AL00	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:02.537	2026-07-14 13:02:02.537	cmrkb3cyo0001y9h6bozaifdg
cmrknur0002mx4hleha5fw200	PAVILION DV6	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:02:02.544	2026-07-14 13:02:02.544	cmrknujxm000b4hle4o2fwrvs
cmrknur0702mz4hledtburyjq	T300	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:02.551	2026-07-14 13:02:02.551	cmrknujxm000b4hle4o2fwrvs
cmrknur0e02n14hleol3egpbg	PCG-3J1L	cmrknujyl000l4hlezisknz7b	2026-07-14 13:02:02.558	2026-07-14 13:02:02.558	cmrknujxm000b4hle4o2fwrvs
cmrknur0l02n34hlejhbnryoi	BLA-AL00	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:02.565	2026-07-14 13:02:02.565	cmrkb3cy40000y9h6lftwhcie
cmrknur0s02n54hle7vt31dne	X452C	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:02.572	2026-07-14 13:02:02.572	cmrknujxm000b4hle4o2fwrvs
cmrknur0y02n74hlednodhcl8	SCL-U31	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:02.579	2026-07-14 13:02:02.579	cmrkb3cy40000y9h6lftwhcie
cmrknur1502n94hle6g910cjj	SM-N985F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:02.585	2026-07-14 13:02:02.585	cmrkb3cy40000y9h6lftwhcie
cmrknur1b02nb4hlecpcbfhi5	TA-1095	cmrknuk1s001i4hleqifj4gnr	2026-07-14 13:02:02.591	2026-07-14 13:02:02.591	cmrkb3cy40000y9h6lftwhcie
cmrknur1h02nd4hle8pn82ryc	ELITE BOOK	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:02:02.598	2026-07-14 13:02:02.598	cmrknujxm000b4hle4o2fwrvs
cmrknur1p02nf4hlefragkoim	SM-G920F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:02.605	2026-07-14 13:02:02.605	cmrkb3cy40000y9h6lftwhcie
cmrknur1v02nh4hleggd6jdaq	A1660	cmrknujzo000w4hlesj7fng18	2026-07-14 13:02:02.612	2026-07-14 13:02:02.612	cmrkb3cy40000y9h6lftwhcie
cmrknur2202nj4hle8a8bc0fo	P01T	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:02.618	2026-07-14 13:02:02.618	cmrkb3cyo0001y9h6bozaifdg
cmrknur2902nl4hlemy5ezwrb	SM-A305F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:02.625	2026-07-14 13:02:02.625	cmrkb3cy40000y9h6lftwhcie
cmrknur2f02nn4hle8d5bhusm	SM-A145F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:02.632	2026-07-14 13:02:02.632	cmrkb3cy40000y9h6lftwhcie
cmrknur2m02np4hle4qyr96i4	NAM-LX9	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:02.638	2026-07-14 13:02:02.638	cmrkb3cy40000y9h6lftwhcie
cmrknur2u02nr4hle0wox1rct	MI MIX 2	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:02.646	2026-07-14 13:02:02.646	cmrkb3cy40000y9h6lftwhcie
cmrknur3002nt4hle8tzaazdh	JLN-LX1	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:02.653	2026-07-14 13:02:02.653	cmrkb3cy40000y9h6lftwhcie
cmrknur3702nv4hlelowq5cut	ASPIRE E5-575	cmrknuk0500114hleha2g5pf3	2026-07-14 13:02:02.659	2026-07-14 13:02:02.659	cmrknujxm000b4hle4o2fwrvs
cmrknur3e02nx4hlel5xxu94x	KIW-L21	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:02.666	2026-07-14 13:02:02.666	cmrkb3cy40000y9h6lftwhcie
cmrknur3k02nz4hlezlz1vl2v	A3500	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:02:02.673	2026-07-14 13:02:02.673	cmrkb3cyo0001y9h6bozaifdg
cmrknur3q02o14hlel2xuthv2	S10-231L	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:02.679	2026-07-14 13:02:02.679	cmrkb3cyo0001y9h6bozaifdg
cmrknur3w02o34hleahg1ob9e	SVF154B1EL	cmrknujyl000l4hlezisknz7b	2026-07-14 13:02:02.684	2026-07-14 13:02:02.684	cmrknujxm000b4hle4o2fwrvs
cmrknur4202o54hlek3me81ac	cl664129	cmrknujzy000z4hlef0vui8me	2026-07-14 13:02:02.691	2026-07-14 13:02:02.691	cmrkb3cy40000y9h6lftwhcie
cmrknur4902o74hletc2xnqk3	A3500 (موبایل)	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:02:02.697	2026-07-14 13:02:02.697	cmrkb3cy40000y9h6lftwhcie
cmrknur4k02o94hle3bfvuyed	KIW-L21	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:02.708	2026-07-14 13:02:02.708	cmrkb3cy40000y9h6lftwhcie
cmrknur4r02ob4hle1p2t6yja	S10-231L (موبایل)	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:02.715	2026-07-14 13:02:02.715	cmrkb3cy40000y9h6lftwhcie
cmrknur5102od4hle6xqvcs6g	SVD11216PGB	cmrknujyl000l4hlezisknz7b	2026-07-14 13:02:02.725	2026-07-14 13:02:02.725	cmrknujxm000b4hle4o2fwrvs
cmrknur5702of4hleirdw39sk	BOB-WAI9AQ	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:02.731	2026-07-14 13:02:02.731	cmrknujxm000b4hle4o2fwrvs
cmrknur5e02oh4hleai4ybcyj	PCG-3C2L	cmrknujyl000l4hlezisknz7b	2026-07-14 13:02:02.738	2026-07-14 13:02:02.738	cmrknujxm000b4hle4o2fwrvs
cmrknur5k02oj4hlel9it93ek	LIO-L29	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:02.744	2026-07-14 13:02:02.744	cmrkb3cy40000y9h6lftwhcie
cmrknur5q02ol4hle0n7yl81f	P7-L10	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:02.75	2026-07-14 13:02:02.75	cmrkb3cy40000y9h6lftwhcie
cmrknur5x02on4hle5sme99pc	SM-G965F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:02.757	2026-07-14 13:02:02.757	cmrkb3cy40000y9h6lftwhcie
cmrknur6402op4hlelgsn5lxe	PAR-LX1M	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:02.764	2026-07-14 13:02:02.764	cmrkb3cy40000y9h6lftwhcie
cmrknur6a02or4hle6fjbo1zn	JSN-L22	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:02.77	2026-07-14 13:02:02.77	cmrkb3cy40000y9h6lftwhcie
cmrknur6h02ot4hlecz1see23	SM-A125F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:02.777	2026-07-14 13:02:02.777	cmrkb3cy40000y9h6lftwhcie
cmrknur6n02ov4hlepgl09xqe	2PYB2	cmrknujzy000z4hlef0vui8me	2026-07-14 13:02:02.783	2026-07-14 13:02:02.783	cmrkb3cy40000y9h6lftwhcie
cmrknur6t02ox4hlelajd6fer	MI 10T LITE 5G	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:02.79	2026-07-14 13:02:02.79	cmrkb3cy40000y9h6lftwhcie
cmrknur6z02oz4hleee09fhy5	HRY-LX1T	cmrknujyo000m4hlecl948w9e	2026-07-14 13:02:02.795	2026-07-14 13:02:02.795	cmrkb3cy40000y9h6lftwhcie
cmrknur7502p14hles48nqp7g	PCG-3G5L	cmrknujyl000l4hlezisknz7b	2026-07-14 13:02:02.802	2026-07-14 13:02:02.802	cmrknujxm000b4hle4o2fwrvs
cmrknur7c02p34hlea72k9wnp	FLA-LX1	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:02.808	2026-07-14 13:02:02.808	cmrkb3cy40000y9h6lftwhcie
cmrknur7i02p54hle6180jpcb	X00DD	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:02.814	2026-07-14 13:02:02.814	cmrkb3cy40000y9h6lftwhcie
cmrknur7o02p74hleh0x2pfia	STREAM 8	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:02:02.82	2026-07-14 13:02:02.82	cmrkb3cyo0001y9h6bozaifdg
cmrknur7u02p94hleqx89ombq	GRA-UL00	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:02.827	2026-07-14 13:02:02.827	cmrkb3cy40000y9h6lftwhcie
cmrknur8002pb4hle6j6y6trc	SM-A528B	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:02.833	2026-07-14 13:02:02.833	cmrkb3cy40000y9h6lftwhcie
cmrknur8702pd4hle6oi9c56y	12	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:02.84	2026-07-14 13:02:02.84	cmrkb3cy40000y9h6lftwhcie
cmrknur8e02pf4hle3mfenudj	THINK BOOK 15 G2	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:02:02.846	2026-07-14 13:02:02.846	cmrknujxm000b4hle4o2fwrvs
cmrknur8l02ph4hlerncakfne	EVA-L19	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:02.853	2026-07-14 13:02:02.853	cmrkb3cy40000y9h6lftwhcie
cmrknur8s02pj4hlegoezs93v	OPJX100	cmrknujzy000z4hlef0vui8me	2026-07-14 13:02:02.86	2026-07-14 13:02:02.86	cmrkb3cy40000y9h6lftwhcie
cmrknur8z02pl4hle1zwpftz0	VIE-L29	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:02.867	2026-07-14 13:02:02.867	cmrkb3cy40000y9h6lftwhcie
cmrknur9602pn4hle1e5pfg43	GL552V	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:02.874	2026-07-14 13:02:02.874	cmrknujxm000b4hle4o2fwrvs
cmrknur9d02pp4hlesla6eo5v	MHA-L29	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:02.881	2026-07-14 13:02:02.881	cmrkb3cy40000y9h6lftwhcie
cmrknur9k02pr4hle4goz5t1y	A7600	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:02:02.888	2026-07-14 13:02:02.888	cmrkb3cyo0001y9h6bozaifdg
cmrknur9r02pt4hle3r3wah5b	K55V	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:02.895	2026-07-14 13:02:02.895	cmrknujxm000b4hle4o2fwrvs
cmrknur9y02pv4hlekawpjvjl	K00G	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:02.902	2026-07-14 13:02:02.902	cmrkb3cyo0001y9h6bozaifdg
cmrknura502px4hlel0deqox3	A1863	cmrknujzo000w4hlesj7fng18	2026-07-14 13:02:02.909	2026-07-14 13:02:02.909	cmrkb3cy40000y9h6lftwhcie
cmrknurad02pz4hlen80ohcps	G6-2297SE	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:02:02.917	2026-07-14 13:02:02.917	cmrknujxm000b4hle4o2fwrvs
cmrknural02q14hle9vr5m5o9	POCO C40	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:02.925	2026-07-14 13:02:02.925	cmrkb3cy40000y9h6lftwhcie
cmrknurat02q34hlee2t41csg	F510U	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:02.933	2026-07-14 13:02:02.933	cmrknujxm000b4hle4o2fwrvs
cmrknurb102q54hle2sexb1js	SM-G950FD	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:02.941	2026-07-14 13:02:02.941	cmrkb3cy40000y9h6lftwhcie
cmrknurb902q74hle8agrl424	2pzf200	cmrknujzy000z4hlef0vui8me	2026-07-14 13:02:02.949	2026-07-14 13:02:02.949	cmrkb3cy40000y9h6lftwhcie
cmrknurbh02q94hle1jt9l4q6	FRD-L09	cmrknujyo000m4hlecl948w9e	2026-07-14 13:02:02.957	2026-07-14 13:02:02.957	cmrkb3cy40000y9h6lftwhcie
cmrknurbp02qb4hleqfcebvzx	SM-G975F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:02.965	2026-07-14 13:02:02.965	cmrkb3cy40000y9h6lftwhcie
cmrknurby02qd4hlepbfxmnsg	K550L	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:02.974	2026-07-14 13:02:02.974	cmrknujxm000b4hle4o2fwrvs
cmrknurc502qf4hlesd1f6w89	LYA-L29	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:02.981	2026-07-14 13:02:02.981	cmrkb3cy40000y9h6lftwhcie
cmrknurcd02qh4hleagvcca4j	Y560-U02	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:02.989	2026-07-14 13:02:02.989	cmrkb3cy40000y9h6lftwhcie
cmrknurck02qj4hle7m2fqv6j	MOTO ONE	cmrknujz5000r4hleshjq47jw	2026-07-14 13:02:02.996	2026-07-14 13:02:02.996	cmrkb3cy40000y9h6lftwhcie
cmrknurcs02ql4hleu754gur5	K513E	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:03.004	2026-07-14 13:02:03.004	cmrknujxm000b4hle4o2fwrvs
cmrknurcz02qn4hle2x0evpkn	MI 10	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:03.011	2026-07-14 13:02:03.011	cmrkb3cy40000y9h6lftwhcie
cmrknurd702qp4hle76gej560	SM-G930F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:03.019	2026-07-14 13:02:03.019	cmrkb3cy40000y9h6lftwhcie
cmrknurde02qr4hlej5at3raa	K53E	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:03.026	2026-07-14 13:02:03.026	cmrknujxm000b4hle4o2fwrvs
cmrknurdl02qt4hleakmbxwn4	A700H	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:03.033	2026-07-14 13:02:03.033	cmrkb3cy40000y9h6lftwhcie
cmrknurds02qv4hle9gk00jwk	S10-201U	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:03.04	2026-07-14 13:02:03.04	cmrkb3cyo0001y9h6bozaifdg
cmrknurdz02qx4hle78n4g5hg	MI 9 LITE	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:03.047	2026-07-14 13:02:03.047	cmrkb3cy40000y9h6lftwhcie
cmrknure602qz4hle0bgjz7qo	K017	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:03.054	2026-07-14 13:02:03.054	cmrkb3cy40000y9h6lftwhcie
cmrknured02r14hledsimw315	UX410U	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:03.061	2026-07-14 13:02:03.061	cmrknujxm000b4hle4o2fwrvs
cmrknurek02r34hlettvgq93k	PROBOOK 450 G2	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:02:03.068	2026-07-14 13:02:03.068	cmrknujxm000b4hle4o2fwrvs
cmrknurer02r54hlecepwup6v	BAH2-L09	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:03.075	2026-07-14 13:02:03.075	cmrkb3cyo0001y9h6bozaifdg
cmrknurex02r74hledmtxt6yi	XIAOMI 11 LITE 5G	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:03.081	2026-07-14 13:02:03.081	cmrkb3cy40000y9h6lftwhcie
cmrknurf402r94hlenuhqxpxs	K45V	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:03.088	2026-07-14 13:02:03.088	cmrknujxm000b4hle4o2fwrvs
cmrknurfa02rb4hlene2jugm8	PCG-41213W	cmrknujyl000l4hlezisknz7b	2026-07-14 13:02:03.095	2026-07-14 13:02:03.095	cmrknujxm000b4hle4o2fwrvs
cmrknurfg02rd4hle6vbelkes	P01MA	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:03.1	2026-07-14 13:02:03.1	cmrkb3cy40000y9h6lftwhcie
cmrknurfm02rf4hle9urpkzs2	SM-A260F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:03.107	2026-07-14 13:02:03.107	cmrkb3cy40000y9h6lftwhcie
cmrknurft02rh4hlev2yjobal	GRA-UL10	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:03.113	2026-07-14 13:02:03.113	cmrkb3cy40000y9h6lftwhcie
cmrknurfz02rj4hles2d0c1kc	MI NOTE 10 LITE	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:03.12	2026-07-14 13:02:03.12	cmrkb3cy40000y9h6lftwhcie
cmrknurg602rl4hle92zccyp8	TB-7703X	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:02:03.126	2026-07-14 13:02:03.126	cmrkb3cyo0001y9h6bozaifdg
cmrknurgc02rn4hlebcu3t21w	MI 11T PRO	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:03.132	2026-07-14 13:02:03.132	cmrkb3cy40000y9h6lftwhcie
cmrknurgi02rp4hleva389nz8	G620-UL01	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:03.138	2026-07-14 13:02:03.138	cmrkb3cy40000y9h6lftwhcie
cmrknurgp02rr4hledz2olgrd	MI 4I	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:03.145	2026-07-14 13:02:03.145	cmrkb3cy40000y9h6lftwhcie
cmrknurgw02rt4hlerazivbn5	MI 6	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:03.152	2026-07-14 13:02:03.152	cmrkb3cy40000y9h6lftwhcie
cmrknurh202rv4hlefaz2tfym	DV6-6190SE	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:02:03.159	2026-07-14 13:02:03.159	cmrknujxm000b4hle4o2fwrvs
cmrknurh802rx4hle1oa07b6q	A1342	cmrknujzo000w4hlesj7fng18	2026-07-14 13:02:03.164	2026-07-14 13:02:03.164	cmrknujxm000b4hle4o2fwrvs
cmrknurhc02rz4hlehw01z39t	ASPIRE 5251	cmrknuk0500114hleha2g5pf3	2026-07-14 13:02:03.169	2026-07-14 13:02:03.169	cmrknujxm000b4hle4o2fwrvs
cmrknurhg02s14hle6rwj6iyy	GA503R	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:03.173	2026-07-14 13:02:03.173	cmrknujxm000b4hle4o2fwrvs
cmrknurhk02s34hleqxvx5hxq	0PM1100	cmrknujzy000z4hlef0vui8me	2026-07-14 13:02:03.176	2026-07-14 13:02:03.176	cmrkb3cy40000y9h6lftwhcie
cmrknurhn02s54hles33ceugj	MI A2	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:03.179	2026-07-14 13:02:03.179	cmrkb3cy40000y9h6lftwhcie
cmrknurhq02s74hlebrazsdyl	SM-G970F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:03.182	2026-07-14 13:02:03.182	cmrkb3cy40000y9h6lftwhcie
cmrknurht02s94hle8el40ukt	TPN-W108	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:02:03.185	2026-07-14 13:02:03.185	cmrknujxm000b4hle4o2fwrvs
cmrknurhw02sb4hleui4hs87s	RT3090BC4	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:02:03.189	2026-07-14 13:02:03.189	cmrknujxm000b4hle4o2fwrvs
cmrknurhz02sd4hleqrwlxwpc	12X	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:03.191	2026-07-14 13:02:03.191	cmrkb3cy40000y9h6lftwhcie
cmrknuri202sf4hlet6y51jl5	SVS131E21W	cmrknujyl000l4hlezisknz7b	2026-07-14 13:02:03.194	2026-07-14 13:02:03.194	cmrknujxm000b4hle4o2fwrvs
cmrknuri402sh4hle1r6myg9g	K42J	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:03.196	2026-07-14 13:02:03.196	cmrknujxm000b4hle4o2fwrvs
cmrknuri602sj4hleavunnyrl	PN071100	cmrknujzy000z4hlef0vui8me	2026-07-14 13:02:03.199	2026-07-14 13:02:03.199	cmrkb3cy40000y9h6lftwhcie
cmrknuri902sl4hleiq3a9vu3	TX300CA	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:03.201	2026-07-14 13:02:03.201	cmrknujxm000b4hle4o2fwrvs
cmrknuric02sn4hlezvfqk2s4	P008 (تبلت)	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:03.204	2026-07-14 13:02:03.204	cmrkb3cyo0001y9h6bozaifdg
cmrknurif02sp4hlewkzidmvb	X008D	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:03.208	2026-07-14 13:02:03.208	cmrkb3cy40000y9h6lftwhcie
cmrknurii02sr4hle88rwkdz4	MSAA8A	cmrknujz9000s4hleu8mshqu7	2026-07-14 13:02:03.21	2026-07-14 13:02:03.21	cmrknujx800074hlexsapxr4z
cmrknurik02st4hleqf6mk3fc	MLA-L11	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:03.212	2026-07-14 13:02:03.212	cmrkb3cy40000y9h6lftwhcie
cmrknurim02sv4hlebagnkftr	SM-A135F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:03.215	2026-07-14 13:02:03.215	cmrkb3cy40000y9h6lftwhcie
cmrknurip02sx4hle7t7i35jj	A55V	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:03.217	2026-07-14 13:02:03.217	cmrknujxm000b4hle4o2fwrvs
cmrknurir02sz4hlev1npd1b9	A500CG	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:03.22	2026-07-14 13:02:03.22	cmrkb3cy40000y9h6lftwhcie
cmrknuriu02t14hleocmwi2ho	TB-8703X	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:02:03.222	2026-07-14 13:02:03.222	cmrkb3cyo0001y9h6bozaifdg
cmrknuriw02t34hlegycrtg44	REDMI NOTE 10S	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:03.224	2026-07-14 13:02:03.224	cmrkb3cy40000y9h6lftwhcie
cmrknuriy02t54hle9exmmqow	TIT-AL00	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:03.227	2026-07-14 13:02:03.227	cmrkb3cy40000y9h6lftwhcie
cmrknurj002t74hleykt1hggu	MI 5	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:03.229	2026-07-14 13:02:03.229	cmrkb3cy40000y9h6lftwhcie
cmrknurj302t94hlei34iffui	2PZC300	cmrknujzy000z4hlef0vui8me	2026-07-14 13:02:03.231	2026-07-14 13:02:03.231	cmrkb3cy40000y9h6lftwhcie
cmrknurj602tb4hlehsecwrx5	REDMI A1 PLUS	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:03.234	2026-07-14 13:02:03.234	cmrkb3cy40000y9h6lftwhcie
cmrknurj902td4hleojcm9xaz	COL-L29	cmrknujyo000m4hlecl948w9e	2026-07-14 13:02:03.237	2026-07-14 13:02:03.237	cmrkb3cy40000y9h6lftwhcie
cmrknurjc02tf4hle6x88qr7x	X510U	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:03.24	2026-07-14 13:02:03.24	cmrknujxm000b4hle4o2fwrvs
cmrknurje02th4hleej2cm8uw	SM-A505F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:03.243	2026-07-14 13:02:03.243	cmrkb3cy40000y9h6lftwhcie
cmrknurjh02tj4hlehpo9e554	SM-T530NU	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:03.245	2026-07-14 13:02:03.245	cmrkb3cyo0001y9h6bozaifdg
cmrknurjk02tl4hle7am0uqrf	SM-A307F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:03.248	2026-07-14 13:02:03.248	cmrkb3cy40000y9h6lftwhcie
cmrknurjn02tn4hle7syulruw	Z851KL	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:03.252	2026-07-14 13:02:03.252	cmrkb3cy40000y9h6lftwhcie
cmrknurjr02tp4hle9deqpobv	MI 8 LITE	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:03.255	2026-07-14 13:02:03.255	cmrkb3cy40000y9h6lftwhcie
cmrknurjw02tr4hlevgx3re8a	SM-A225F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:03.26	2026-07-14 13:02:03.26	cmrkb3cy40000y9h6lftwhcie
cmrknurk002tt4hled3cthgo0	A225F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:03.264	2026-07-14 13:02:03.264	cmrkb3cy40000y9h6lftwhcie
cmrknurk502tv4hledarwecyu	MI 11 ULTRA	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:03.269	2026-07-14 13:02:03.269	cmrkb3cy40000y9h6lftwhcie
cmrknurka02tx4hleju67wrsx	POCO C31	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:03.275	2026-07-14 13:02:03.275	cmrkb3cy40000y9h6lftwhcie
cmrknurkg02tz4hle57645vsu	MI MIX 3	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:03.28	2026-07-14 13:02:03.28	cmrkb3cy40000y9h6lftwhcie
cmrknurkn02u14hlejrt1c70g	BAC-L21	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:03.287	2026-07-14 13:02:03.287	cmrkb3cy40000y9h6lftwhcie
cmrknurku02u34hlescgf4wbm	JNL-LX1	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:03.294	2026-07-14 13:02:03.294	cmrkb3cy40000y9h6lftwhcie
cmrknurl002u54hleq42q0umq	ONE_M8	cmrknujzy000z4hlef0vui8me	2026-07-14 13:02:03.301	2026-07-14 13:02:03.301	cmrkb3cy40000y9h6lftwhcie
cmrknurl802u74hleswgvo8y4	POCO M3 PRO	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:03.308	2026-07-14 13:02:03.308	cmrkb3cy40000y9h6lftwhcie
cmrknurlf02u94hlekttodsxx	MI 5S PLUS	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:03.315	2026-07-14 13:02:03.315	cmrkb3cy40000y9h6lftwhcie
cmrknurlm02ub4hlep6w81eaq	SM-A520F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:03.322	2026-07-14 13:02:03.322	cmrkb3cy40000y9h6lftwhcie
cmrknurls02ud4hlembg5bq8t	MI PAD 2	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:03.328	2026-07-14 13:02:03.328	cmrkb3cyo0001y9h6bozaifdg
cmrknurlz02uf4hleos55v56n	CHM-U01	cmrknujyo000m4hlecl948w9e	2026-07-14 13:02:03.335	2026-07-14 13:02:03.335	cmrkb3cy40000y9h6lftwhcie
cmrknurm502uh4hlec35yowg1	IDEAPAD MIIX 310	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:02:03.341	2026-07-14 13:02:03.341	cmrknujxm000b4hle4o2fwrvs
cmrknurmb02uj4hlel2edidir	SM-A750F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:03.348	2026-07-14 13:02:03.348	cmrkb3cy40000y9h6lftwhcie
cmrknurmi02ul4hlezd2ibd02	SM-A750	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:03.354	2026-07-14 13:02:03.354	cmrkb3cy40000y9h6lftwhcie
cmrknurmp02un4hleb4ukwnuy	REDMI 10	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:03.361	2026-07-14 13:02:03.361	cmrkb3cy40000y9h6lftwhcie
cmrknurmv02up4hlekstjdn76	A1778	cmrknujzo000w4hlesj7fng18	2026-07-14 13:02:03.367	2026-07-14 13:02:03.367	cmrkb3cy40000y9h6lftwhcie
cmrknurn202ur4hlezgifof93	TRAVELMATE 5730	cmrknuk0500114hleha2g5pf3	2026-07-14 13:02:03.375	2026-07-14 13:02:03.375	cmrknujxm000b4hle4o2fwrvs
cmrknurn802ut4hleiflf8pod	MI 10T PRO 5G	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:03.381	2026-07-14 13:02:03.381	cmrkb3cy40000y9h6lftwhcie
cmrknurnf02uv4hlep96ltsyi	CTR-LX2	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:03.387	2026-07-14 13:02:03.387	cmrkb3cy40000y9h6lftwhcie
cmrknurnl02ux4hlemp6gw3sr	MI 5 PRO	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:03.393	2026-07-14 13:02:03.393	cmrkb3cy40000y9h6lftwhcie
cmrknurns02uz4hlehv3fdcd1	ARE-L22HN	cmrknujyo000m4hlecl948w9e	2026-07-14 13:02:03.4	2026-07-14 13:02:03.4	cmrkb3cy40000y9h6lftwhcie
cmrknurnz02v14hlezzze1luk	RIO-L01	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:03.407	2026-07-14 13:02:03.407	cmrkb3cy40000y9h6lftwhcie
cmrknuro602v34hleg39gtijg	MI 9T PRO	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:03.414	2026-07-14 13:02:03.414	cmrkb3cy40000y9h6lftwhcie
cmrknurod02v54hle5nrqj9qq	SM-G900H	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:03.421	2026-07-14 13:02:03.421	cmrkb3cy40000y9h6lftwhcie
cmrknurok02v74hlefqq7c4xo	2PYA200	cmrknujzy000z4hlef0vui8me	2026-07-14 13:02:03.428	2026-07-14 13:02:03.428	cmrkb3cy40000y9h6lftwhcie
cmrknuroq02v94hle25gx0wcc	12T	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:03.434	2026-07-14 13:02:03.434	cmrkb3cy40000y9h6lftwhcie
cmrknuroy02vb4hleqban5nkk	XPAW004 (موبایل)	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:03.442	2026-07-14 13:02:03.442	cmrkb3cy40000y9h6lftwhcie
cmrknurp902vd4hle8jn1bjav	DUB-LX1	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:03.453	2026-07-14 13:02:03.453	cmrkb3cy40000y9h6lftwhcie
cmrknurpg02vf4hlet4lwi9wk	11T PRO	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:03.46	2026-07-14 13:02:03.46	cmrkb3cy40000y9h6lftwhcie
cmrknurpm02vh4hleb8a73pek	REDMI 4X	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:03.467	2026-07-14 13:02:03.467	cmrkb3cy40000y9h6lftwhcie
cmrknurpu02vj4hlej9snj898	NEN-L22	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:03.474	2026-07-14 13:02:03.474	cmrkb3cy40000y9h6lftwhcie
cmrknurq002vl4hleqyyh9e3q	MI 11 PRO	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:03.48	2026-07-14 13:02:03.48	cmrkb3cy40000y9h6lftwhcie
cmrknurq702vn4hle8iu3qjq6	REDMI NOTE 6 PRO	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:03.487	2026-07-14 13:02:03.487	cmrkb3cy40000y9h6lftwhcie
cmrknurqe02vp4hle0jswfzk3	REDMI NOTE 7	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:03.494	2026-07-14 13:02:03.494	cmrkb3cy40000y9h6lftwhcie
cmrknurqk02vr4hler7beqkzr	POCO M4 PRO 5G	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:03.501	2026-07-14 13:02:03.501	cmrkb3cy40000y9h6lftwhcie
cmrknurqs02vt4hlej8prjyqx	BLN-L21	cmrknujyo000m4hlecl948w9e	2026-07-14 13:02:03.508	2026-07-14 13:02:03.508	cmrkb3cy40000y9h6lftwhcie
cmrknurqy02vv4hle9arupglk	VOG-L29	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:03.514	2026-07-14 13:02:03.514	cmrkb3cy40000y9h6lftwhcie
cmrknurr502vx4hle7a5jpm1p	SM-A105F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:03.521	2026-07-14 13:02:03.521	cmrkb3cy40000y9h6lftwhcie
cmrknurrb02vz4hlev0qzd26z	POCO X3 NFC	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:03.527	2026-07-14 13:02:03.527	cmrkb3cy40000y9h6lftwhcie
cmrknurri02w14hlepwl3oofa	PROBOOK 4520S	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:02:03.534	2026-07-14 13:02:03.534	cmrknujxm000b4hle4o2fwrvs
cmrknurrq02w34hlev25fzcq0	MI 8	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:03.542	2026-07-14 13:02:03.542	cmrkb3cy40000y9h6lftwhcie
cmrknurrx02w54hlet6dxl2xt	FRL-L22	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:03.549	2026-07-14 13:02:03.549	cmrkb3cy40000y9h6lftwhcie
cmrknurs302w74hlekkd59yjw	REDMI NOTE 11 PRO	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:03.556	2026-07-14 13:02:03.556	cmrkb3cy40000y9h6lftwhcie
cmrknursb02w94hlee8h059f5	SM-G955F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:03.563	2026-07-14 13:02:03.563	cmrkb3cy40000y9h6lftwhcie
cmrknursh02wb4hlefpd54bm4	SM-A720F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:03.57	2026-07-14 13:02:03.57	cmrkb3cy40000y9h6lftwhcie
cmrknurso02wd4hle2vyulth9	SM-M515F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:03.576	2026-07-14 13:02:03.576	cmrkb3cy40000y9h6lftwhcie
cmrknursv02wf4hleqwwv1jkw	PCG-8111L	cmrknujyl000l4hlezisknz7b	2026-07-14 13:02:03.583	2026-07-14 13:02:03.583	cmrknujxm000b4hle4o2fwrvs
cmrknurt202wh4hle1uhixcnk	REDMI 8A	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:03.59	2026-07-14 13:02:03.59	cmrkb3cy40000y9h6lftwhcie
cmrknurt802wj4hlenkm1g1p1	2PZM100 U-2U	cmrknujzy000z4hlef0vui8me	2026-07-14 13:02:03.596	2026-07-14 13:02:03.596	cmrkb3cy40000y9h6lftwhcie
cmrknurtf02wl4hle9qhocufy	POCO X4 PRO 5G	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:03.603	2026-07-14 13:02:03.603	cmrkb3cy40000y9h6lftwhcie
cmrknurtl02wn4hleq8gcouum	BLA-L29	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:03.61	2026-07-14 13:02:03.61	cmrkb3cy40000y9h6lftwhcie
cmrknurts02wp4hleq41crg4w	MI 11T	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:03.616	2026-07-14 13:02:03.616	cmrkb3cy40000y9h6lftwhcie
cmrknurtz02wr4hle80og8fon	POT-LX1AF	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:03.623	2026-07-14 13:02:03.623	cmrkb3cy40000y9h6lftwhcie
cmrknuru502wt4hle5oyt9fiu	REDMI 6	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:03.63	2026-07-14 13:02:03.63	cmrkb3cy40000y9h6lftwhcie
cmrknurud02wv4hles1vy9zql	A1502 (موبایل)	cmrknujzo000w4hlesj7fng18	2026-07-14 13:02:03.637	2026-07-14 13:02:03.637	cmrkb3cy40000y9h6lftwhcie
cmrknurun02wx4hlefzl620dj	POCO X3	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:03.647	2026-07-14 13:02:03.647	cmrkb3cy40000y9h6lftwhcie
cmrknuruu02wz4hle7760kvcf	MI 10 PRO	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:03.654	2026-07-14 13:02:03.654	cmrkb3cy40000y9h6lftwhcie
cmrknurv002x14hlely1ge704	SM-A325F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:03.661	2026-07-14 13:02:03.661	cmrkb3cy40000y9h6lftwhcie
cmrknurv702x34hle7iu4ikqt	SM-A226B	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:03.668	2026-07-14 13:02:03.668	cmrkb3cy40000y9h6lftwhcie
cmrknurve02x54hle986v0bpw	REDMI 2	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:03.674	2026-07-14 13:02:03.674	cmrkb3cy40000y9h6lftwhcie
cmrknurvj02x74hlelqketbt7	LIO-N29	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:03.68	2026-07-14 13:02:03.68	cmrkb3cy40000y9h6lftwhcie
cmrknurvq02x94hle4lypyqzo	AQM-LX1	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:03.686	2026-07-14 13:02:03.686	cmrkb3cy40000y9h6lftwhcie
cmrknurvw02xb4hleam37ugp0	SM-A515F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:03.693	2026-07-14 13:02:03.693	cmrkb3cy40000y9h6lftwhcie
cmrknurw302xd4hlebc2bzird	MRD-LX1F	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:03.699	2026-07-14 13:02:03.699	cmrkb3cy40000y9h6lftwhcie
cmrknurwa02xf4hle49vtia89	REDMI NOTE 10 5G	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:03.706	2026-07-14 13:02:03.706	cmrkb3cy40000y9h6lftwhcie
cmrknurwg02xh4hle8o0vmnxc	SVP132A1CL	cmrknujyl000l4hlezisknz7b	2026-07-14 13:02:03.712	2026-07-14 13:02:03.712	cmrknujxm000b4hle4o2fwrvs
cmrknurwn02xj4hlean3hkctx	X017DA	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:03.719	2026-07-14 13:02:03.719	cmrkb3cy40000y9h6lftwhcie
cmrknurwt02xl4hle6yk66ejd	XMA2006	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:03.725	2026-07-14 13:02:03.725	cmrknujxm000b4hle4o2fwrvs
cmrknurwz02xn4hle40zsm388	X756U	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:03.731	2026-07-14 13:02:03.731	cmrknujxm000b4hle4o2fwrvs
cmrknurx502xp4hleaton82l6	SM-J320	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:03.738	2026-07-14 13:02:03.738	cmrkb3cy40000y9h6lftwhcie
cmrknurxc02xr4hleux68huf1	X01AD	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:03.744	2026-07-14 13:02:03.744	cmrkb3cy40000y9h6lftwhcie
cmrknurxi02xt4hlejley2eq2	LND-L29	cmrknujyo000m4hlecl948w9e	2026-07-14 13:02:03.75	2026-07-14 13:02:03.75	cmrkb3cy40000y9h6lftwhcie
cmrknurxq02xv4hlexi18uarr	MI 4	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:03.758	2026-07-14 13:02:03.758	cmrkb3cy40000y9h6lftwhcie
cmrknurxy02xx4hle8kgf158k	PAVILION DV4	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:02:03.766	2026-07-14 13:02:03.766	cmrknujxm000b4hle4o2fwrvs
cmrknury602xz4hletfgfdcv7	G565	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:02:03.774	2026-07-14 13:02:03.774	cmrknujxm000b4hle4o2fwrvs
cmrknuryc02y14hleaqul1iky	PAVILION DV9000	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:02:03.781	2026-07-14 13:02:03.781	cmrknujxm000b4hle4o2fwrvs
cmrknuryl02y34hlego733abe	TRT-L21A	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:03.789	2026-07-14 13:02:03.789	cmrkb3cy40000y9h6lftwhcie
cmrknuryt02y54hle1b4zewtg	N551J	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:03.797	2026-07-14 13:02:03.797	cmrknujxm000b4hle4o2fwrvs
cmrknurz002y74hlelxi6g9va	K53S	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:03.804	2026-07-14 13:02:03.804	cmrknujxm000b4hle4o2fwrvs
cmrknurz702y94hleacmmgw34	SM-T355Y	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:03.811	2026-07-14 13:02:03.811	cmrkb3cyo0001y9h6bozaifdg
cmrknurzf02yb4hlemgzwsp1h	K017 (تبلت)	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:03.819	2026-07-14 13:02:03.819	cmrkb3cyo0001y9h6bozaifdg
cmrknurzo02yd4hle4y87rywg	POCO PHONE F1	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:03.829	2026-07-14 13:02:03.829	cmrkb3cy40000y9h6lftwhcie
cmrknurzv02yf4hlei2hci9at	S10-231W	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:03.835	2026-07-14 13:02:03.835	cmrkb3cyo0001y9h6bozaifdg
cmrknus0102yh4hlexdqbt1a3	SM-A705FN	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:03.841	2026-07-14 13:02:03.841	cmrkb3cy40000y9h6lftwhcie
cmrknus0702yj4hleqoatfjbw	REDMI NOTE 10 PRO MAX	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:03.847	2026-07-14 13:02:03.847	cmrkb3cy40000y9h6lftwhcie
cmrknus0d02yl4hlekpevmlhn	REDMI 8	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:03.854	2026-07-14 13:02:03.854	cmrkb3cy40000y9h6lftwhcie
cmrknus0l02yn4hlezo2m40jx	MI 9T	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:03.861	2026-07-14 13:02:03.861	cmrkb3cy40000y9h6lftwhcie
cmrknus0s02yp4hlewnpjdy14	S7-721U	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:03.868	2026-07-14 13:02:03.868	cmrkb3cyo0001y9h6bozaifdg
cmrknus0y02yr4hlewdmki1c6	REDMI NOTE 11	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:03.874	2026-07-14 13:02:03.874	cmrkb3cy40000y9h6lftwhcie
cmrknus1402yt4hle428qv43y	SM-A207F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:03.88	2026-07-14 13:02:03.88	cmrkb3cy40000y9h6lftwhcie
cmrknus1a02yv4hle3y6a703s	SM-A315F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:03.887	2026-07-14 13:02:03.887	cmrkb3cy40000y9h6lftwhcie
cmrknus1h02yx4hle22bs88h1	ASPIRE 6920	cmrknuk0500114hleha2g5pf3	2026-07-14 13:02:03.893	2026-07-14 13:02:03.893	cmrknujxm000b4hle4o2fwrvs
cmrknus1o02yz4hled2vvh1gd	POCO M5	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:03.9	2026-07-14 13:02:03.9	cmrkb3cy40000y9h6lftwhcie
cmrknus1v02z14hleh3ioyxxq	POCO F3	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:03.907	2026-07-14 13:02:03.907	cmrkb3cy40000y9h6lftwhcie
cmrknus2102z34hleck2d2qhu	ELS-AN00	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:03.914	2026-07-14 13:02:03.914	cmrkb3cy40000y9h6lftwhcie
cmrknus2902z54hle0bm6fi28	G510	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:02:03.921	2026-07-14 13:02:03.921	cmrknujxm000b4hle4o2fwrvs
cmrknus2g02z74hled57ibu0a	L58041	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:02:03.928	2026-07-14 13:02:03.928	cmrkb3cy40000y9h6lftwhcie
cmrknus2m02z94hlea6dbc33o	DESIRE 816G	cmrknujzy000z4hlef0vui8me	2026-07-14 13:02:03.935	2026-07-14 13:02:03.935	cmrkb3cy40000y9h6lftwhcie
cmrknus2t02zb4hleprp9ikw2	REDMI NOTE 9T	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:03.941	2026-07-14 13:02:03.941	cmrkb3cy40000y9h6lftwhcie
cmrknus3002zd4hlew3crxigh	REDMI NOTE 11 PRO PLUS 5G	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:03.948	2026-07-14 13:02:03.948	cmrkb3cy40000y9h6lftwhcie
cmrknus3602zf4hleub4e62pg	SM-A115F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:03.955	2026-07-14 13:02:03.955	cmrkb3cy40000y9h6lftwhcie
cmrknus3d02zh4hlebs66uvy7	MI NOTE 3	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:03.961	2026-07-14 13:02:03.961	cmrkb3cy40000y9h6lftwhcie
cmrknus3k02zj4hlew5k0nk9o	KIW-L21	cmrknujyo000m4hlecl948w9e	2026-07-14 13:02:03.968	2026-07-14 13:02:03.968	cmrkb3cy40000y9h6lftwhcie
cmrknus3r02zl4hler88gykmx	ALE-L21	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:03.975	2026-07-14 13:02:03.975	cmrkb3cy40000y9h6lftwhcie
cmrknus3x02zn4hle9485qdhb	POCO M3	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:03.982	2026-07-14 13:02:03.982	cmrkb3cy40000y9h6lftwhcie
cmrknus4402zp4hlem8rkfrdy	REDMI NOTE 8 PRO	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:03.988	2026-07-14 13:02:03.988	cmrkb3cy40000y9h6lftwhcie
cmrknus4a02zr4hleobwcu6me	LATITUDE 10-ST2	cmrknujzd000t4hle1ujh33no	2026-07-14 13:02:03.995	2026-07-14 13:02:03.995	cmrknujxm000b4hle4o2fwrvs
cmrknus4h02zt4hle6rekorbe	NOTE 4X	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:04.001	2026-07-14 13:02:04.001	cmrkb3cy40000y9h6lftwhcie
cmrknus4p02zv4hlewn32kche	X555L (لپ تاپ)	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:04.009	2026-07-14 13:02:04.009	cmrknujxm000b4hle4o2fwrvs
cmrknus5002zx4hle0dpcb91g	MYA-L22	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:04.02	2026-07-14 13:02:04.02	cmrkb3cy40000y9h6lftwhcie
cmrknus5702zz4hler6xvpz51	N552V (لپ تاپ)	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:04.027	2026-07-14 13:02:04.027	cmrknujxm000b4hle4o2fwrvs
cmrknus5h03014hle10e0jrjh	3168NGW	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:02:04.037	2026-07-14 13:02:04.037	cmrknujxm000b4hle4o2fwrvs
cmrknus5n03034hle07msaarq	REDMI 9C	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:04.043	2026-07-14 13:02:04.043	cmrkb3cy40000y9h6lftwhcie
cmrknus5t03054hlewnplpgsk	REDMI NOTE 5A	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:04.049	2026-07-14 13:02:04.049	cmrkb3cy40000y9h6lftwhcie
cmrknus5z03074hlesvoo7arz	ALP-L29	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:04.055	2026-07-14 13:02:04.055	cmrkb3cy40000y9h6lftwhcie
cmrknus6503094hlei3ojkzsu	LDN-L21	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:04.061	2026-07-14 13:02:04.061	cmrkb3cy40000y9h6lftwhcie
cmrknus6b030b4hlefc0zl2lj	POCO F2 PRO	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:04.067	2026-07-14 13:02:04.067	cmrkb3cy40000y9h6lftwhcie
cmrknus6h030d4hlexpe8mjbq	K571G	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:04.074	2026-07-14 13:02:04.074	cmrknujxm000b4hle4o2fwrvs
cmrknus6n030f4hlet8o9tonj	CAN-L11	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:04.079	2026-07-14 13:02:04.079	cmrkb3cy40000y9h6lftwhcie
cmrknus6t030h4hlen9tsrfth	TP510U	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:04.085	2026-07-14 13:02:04.085	cmrkb3cy40000y9h6lftwhcie
cmrknus6z030j4hleua1rmwi0	MI 8 SE	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:04.092	2026-07-14 13:02:04.092	cmrkb3cy40000y9h6lftwhcie
cmrknus75030l4hlesmwjlz12	0P6B100	cmrknujzy000z4hlef0vui8me	2026-07-14 13:02:04.097	2026-07-14 13:02:04.097	cmrkb3cy40000y9h6lftwhcie
cmrknus7b030n4hle1vjvoh5g	K542U	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:04.103	2026-07-14 13:02:04.103	cmrknujxm000b4hle4o2fwrvs
cmrknus7h030p4hle9gpzsz1x	2PST610	cmrknujzy000z4hlef0vui8me	2026-07-14 13:02:04.11	2026-07-14 13:02:04.11	cmrkb3cy40000y9h6lftwhcie
cmrknus7n030r4hle8r82udog	REDMI 9	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:04.116	2026-07-14 13:02:04.116	cmrkb3cy40000y9h6lftwhcie
cmrknus7u030t4hleqemiqfau	DV7-4160EG	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:02:04.122	2026-07-14 13:02:04.122	cmrknujxm000b4hle4o2fwrvs
cmrknus80030v4hleepdobkl8	MI 10T 5G	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:04.128	2026-07-14 13:02:04.128	cmrkb3cy40000y9h6lftwhcie
cmrknus85030x4hle6dp2o0zh	ASPIRE F5-573	cmrknuk0500114hleha2g5pf3	2026-07-14 13:02:04.134	2026-07-14 13:02:04.134	cmrknujxm000b4hle4o2fwrvs
cmrknus8c030z4hle6spk49ki	MI NOTE 6 PRO	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:04.14	2026-07-14 13:02:04.14	cmrkb3cy40000y9h6lftwhcie
cmrknus8i03114hletjrabgwq	REDMI NOTE 10	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:04.146	2026-07-14 13:02:04.146	cmrkb3cy40000y9h6lftwhcie
cmrknus8o03134hlexprg8hg5	K012	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:04.152	2026-07-14 13:02:04.152	cmrkb3cyo0001y9h6bozaifdg
cmrknus8u03154hlebphsx016	REDMI K50	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:04.158	2026-07-14 13:02:04.158	cmrkb3cy40000y9h6lftwhcie
cmrknus9003174hlewb725ycu	R542U	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:04.164	2026-07-14 13:02:04.164	cmrknujxm000b4hle4o2fwrvs
cmrknus9603194hleywjvrm9l	G531G	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:04.17	2026-07-14 13:02:04.17	cmrknujxm000b4hle4o2fwrvs
cmrknus9c031b4hleij04sika	2Q4D100	cmrknujzy000z4hlef0vui8me	2026-07-14 13:02:04.177	2026-07-14 13:02:04.177	cmrkb3cy40000y9h6lftwhcie
cmrknus9i031d4hleoktyupw4	REDMI NOTE 9S	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:04.182	2026-07-14 13:02:04.182	cmrkb3cy40000y9h6lftwhcie
cmrknus9o031f4hlez60267k2	REDMI NOTE 10 PRO	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:04.189	2026-07-14 13:02:04.189	cmrkb3cy40000y9h6lftwhcie
cmrknus9u031h4hle3zs5dpep	X541U	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:04.195	2026-07-14 13:02:04.195	cmrknujxm000b4hle4o2fwrvs
cmrknusa1031j4hlelg4gaiky	POCO X3 GT 5G	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:04.201	2026-07-14 13:02:04.201	cmrkb3cy40000y9h6lftwhcie
cmrknusa7031l4hlese5bukdo	MI NOTE 5	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:04.208	2026-07-14 13:02:04.208	cmrkb3cy40000y9h6lftwhcie
cmrknusad031n4hlek5289qsp	PRA-LA1	cmrknujyo000m4hlecl948w9e	2026-07-14 13:02:04.214	2026-07-14 13:02:04.214	cmrkb3cy40000y9h6lftwhcie
cmrknusaj031p4hle3j9qd6q5	MI NOTE 10	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:04.22	2026-07-14 13:02:04.22	cmrkb3cy40000y9h6lftwhcie
cmrknusaq031r4hle8qrxi3ry	JAD-LX9	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:04.226	2026-07-14 13:02:04.226	cmrkb3cy40000y9h6lftwhcie
cmrknusav031t4hlesq5g95tw	X550L	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:04.232	2026-07-14 13:02:04.232	cmrknujxm000b4hle4o2fwrvs
cmrknusb2031v4hlexo2rlaxg	ELITE X2 (تبلت)	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:02:04.238	2026-07-14 13:02:04.238	cmrkb3cyo0001y9h6bozaifdg
cmrknusbb031x4hle7joibn68	RT3290	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:02:04.248	2026-07-14 13:02:04.248	cmrknujxm000b4hle4o2fwrvs
cmrknusbi031z4hle49nffazu	MI MAX3	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:04.254	2026-07-14 13:02:04.254	cmrkb3cy40000y9h6lftwhcie
cmrknusbp03214hleo9zaon5e	N550J	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:04.261	2026-07-14 13:02:04.261	cmrknujxm000b4hle4o2fwrvs
cmrknusbw03234hlexzazbqrl	A1661	cmrknujzo000w4hlesj7fng18	2026-07-14 13:02:04.268	2026-07-14 13:02:04.268	cmrkb3cy40000y9h6lftwhcie
cmrknusc203254hlew2spvu26	REDMI NOTE 9 PRO	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:04.274	2026-07-14 13:02:04.274	cmrkb3cy40000y9h6lftwhcie
cmrknusc903274hle99wb20e9	REDMI NOTE 11S	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:04.281	2026-07-14 13:02:04.281	cmrkb3cy40000y9h6lftwhcie
cmrknuscf03294hlei5t6wz29	REDMI NOTE 8T	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:04.287	2026-07-14 13:02:04.287	cmrkb3cy40000y9h6lftwhcie
cmrknuscm032b4hlehmqse1r8	REDMI 9A	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:04.294	2026-07-14 13:02:04.294	cmrkb3cy40000y9h6lftwhcie
cmrknuscs032d4hleuy8bagxq	SM-G935F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:04.3	2026-07-14 13:02:04.3	cmrkb3cy40000y9h6lftwhcie
cmrknusd0032f4hlen5oyzfzd	POCO M4 PRO	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:04.308	2026-07-14 13:02:04.308	cmrkb3cy40000y9h6lftwhcie
cmrknusd6032h4hle1fqz7kto	GEM-L01	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:04.315	2026-07-14 13:02:04.315	cmrkb3cyo0001y9h6bozaifdg
cmrknusde032j4hlenxdh2yqj	BLACK SHARK 4	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:04.322	2026-07-14 13:02:04.322	cmrkb3cy40000y9h6lftwhcie
cmrknusdk032l4hleev78zdyt	FIG-LA1	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:04.328	2026-07-14 13:02:04.328	cmrkb3cy40000y9h6lftwhcie
cmrknusdq032n4hlem7sfwxnc	REDMI 9T	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:04.335	2026-07-14 13:02:04.335	cmrkb3cy40000y9h6lftwhcie
cmrknusdx032p4hled5k27zvu	SM-J730	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:04.342	2026-07-14 13:02:04.342	cmrkb3cy40000y9h6lftwhcie
cmrknuse3032r4hler9r78tx0	10G2	cmrknuk17001c4hlemkzvs9py	2026-07-14 13:02:04.348	2026-07-14 13:02:04.348	cmrkb3cyo0001y9h6bozaifdg
cmrknusea032t4hleo24ylbc7	MI 9	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:04.354	2026-07-14 13:02:04.354	cmrkb3cy40000y9h6lftwhcie
cmrknuseg032v4hleruxx2f64	WAS-LX1A	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:04.36	2026-07-14 13:02:04.36	cmrkb3cy40000y9h6lftwhcie
cmrknusem032x4hle6fhifjd6	ANE-LX1	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:04.367	2026-07-14 13:02:04.367	cmrkb3cy40000y9h6lftwhcie
cmrknuset032z4hleop5fcpyh	POCO M3 PRO 5G	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:04.373	2026-07-14 13:02:04.373	cmrkb3cy40000y9h6lftwhcie
cmrknusez03314hle881gf5vr	REDMI NOTE 9	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:04.38	2026-07-14 13:02:04.38	cmrkb3cy40000y9h6lftwhcie
cmrknusf603334hlere14c926	JKM-LX1	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:04.386	2026-07-14 13:02:04.386	cmrkb3cy40000y9h6lftwhcie
cmrknusfc03354hletvcgbdfn	MI A2 LITE	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:04.393	2026-07-14 13:02:04.393	cmrkb3cy40000y9h6lftwhcie
cmrknusfj03374hlelkcjtkae	11T	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:04.399	2026-07-14 13:02:04.399	cmrkb3cy40000y9h6lftwhcie
cmrknusfq03394hlelz34dvai	STK-L21	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:04.406	2026-07-14 13:02:04.406	cmrkb3cy40000y9h6lftwhcie
cmrknusfx033b4hledhnnhnhk	MI 10 LITE 5G	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:04.414	2026-07-14 13:02:04.414	cmrkb3cy40000y9h6lftwhcie
cmrknusg4033d4hle86ebwxp2	K541U	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:04.42	2026-07-14 13:02:04.42	cmrknujxm000b4hle4o2fwrvs
cmrknusga033f4hlelpb105q2	MI 11 LITE	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:04.426	2026-07-14 13:02:04.426	cmrkb3cy40000y9h6lftwhcie
cmrknusgh033h4hlevtiryul9	REDMI NOTE 11 PRO 5G	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:04.433	2026-07-14 13:02:04.433	cmrkb3cy40000y9h6lftwhcie
cmrknusgo033j4hleeuo05v6l	YT3-850M (موبایل)	cmrknuk29001m4hle7f34tg5a	2026-07-14 13:02:04.44	2026-07-14 13:02:04.44	cmrkb3cy40000y9h6lftwhcie
cmrknusgz033l4hle6nh48lk9	VTR-L29	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:04.451	2026-07-14 13:02:04.451	cmrkb3cy40000y9h6lftwhcie
cmrknush6033n4hle7nm9hk02	P7-L01	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:04.458	2026-07-14 13:02:04.458	cmrkb3cy40000y9h6lftwhcie
cmrknushc033p4hleezt3rmt8	MI A3	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:04.464	2026-07-14 13:02:04.464	cmrkb3cy40000y9h6lftwhcie
cmrknushj033r4hlew299j3tk	X554L	cmrknujyb000i4hleung9zde3	2026-07-14 13:02:04.472	2026-07-14 13:02:04.472	cmrknujxm000b4hle4o2fwrvs
cmrknushp033t4hleyjwz55sr	0PMG200	cmrknujzy000z4hlef0vui8me	2026-07-14 13:02:04.478	2026-07-14 13:02:04.478	cmrkb3cy40000y9h6lftwhcie
cmrknushw033v4hletkgm2ouv	REDMI NOTE 8	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:04.484	2026-07-14 13:02:04.484	cmrkb3cy40000y9h6lftwhcie
cmrknusi2033x4hlezvyznauv	YAL-L21	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:04.491	2026-07-14 13:02:04.491	cmrkb3cy40000y9h6lftwhcie
cmrknusi9033z4hle0xrfnk5k	RNE-L21	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:04.497	2026-07-14 13:02:04.497	cmrkb3cy40000y9h6lftwhcie
cmrknusif03414hle3noop88e	G510-0200	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:04.504	2026-07-14 13:02:04.504	cmrkb3cy40000y9h6lftwhcie
cmrknusim03434hle1340ka06	F3311	cmrknujyl000l4hlezisknz7b	2026-07-14 13:02:04.511	2026-07-14 13:02:04.511	cmrkb3cy40000y9h6lftwhcie
cmrknusit03454hleef61mk1w	BKK-LX2	cmrknujyo000m4hlecl948w9e	2026-07-14 13:02:04.517	2026-07-14 13:02:04.517	cmrkb3cy40000y9h6lftwhcie
cmrknusj003474hle666vxreo	MT7-TL10	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:04.524	2026-07-14 13:02:04.524	cmrkb3cy40000y9h6lftwhcie
cmrknusj603494hleqc2xez2b	VNS-L21	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:04.53	2026-07-14 13:02:04.53	cmrkb3cy40000y9h6lftwhcie
cmrknusjc034b4hleqi4q7irr	T1-701U	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:04.536	2026-07-14 13:02:04.536	cmrkb3cy40000y9h6lftwhcie
cmrknusji034d4hle3q877ysq	JNY-LX1	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:04.543	2026-07-14 13:02:04.543	cmrkb3cy40000y9h6lftwhcie
cmrknusjp034f4hle5p9bu8fp	MAR-LX1M	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:04.55	2026-07-14 13:02:04.55	cmrkb3cy40000y9h6lftwhcie
cmrknusjx034h4hlel077efkq	Y635-L21	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:04.557	2026-07-14 13:02:04.557	cmrkb3cy40000y9h6lftwhcie
cmrknusk3034j4hle92gl94ax	POCO X3 PRO	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:04.563	2026-07-14 13:02:04.563	cmrkb3cy40000y9h6lftwhcie
cmrknuska034l4hleqnin6v3a	0PK7110	cmrknujzy000z4hlef0vui8me	2026-07-14 13:02:04.57	2026-07-14 13:02:04.57	cmrkb3cy40000y9h6lftwhcie
cmrknuskg034n4hlemtyal3q3	E5-571G	cmrknuk0500114hleha2g5pf3	2026-07-14 13:02:04.577	2026-07-14 13:02:04.577	cmrknujxm000b4hle4o2fwrvs
cmrknuskn034p4hleze4exe4l	SM-A107F	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:04.583	2026-07-14 13:02:04.583	cmrknujxm000b4hle4o2fwrvs
cmrknusku034r4hlewktpk55k	SM-A107F (موبایل)	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:04.59	2026-07-14 13:02:04.59	cmrkb3cy40000y9h6lftwhcie
cmrknusl4034t4hlef19hibfb	dg200	cmrknuk0100104hle0biwkdw8	2026-07-14 13:02:04.6	2026-07-14 13:02:04.6	cmrknujx200054hlexj2ts9xq
cmrknuslb034v4hleeqaes1ky	edge 30	cmrknujz5000r4hleshjq47jw	2026-07-14 13:02:04.607	2026-07-14 13:02:04.607	cmrkb3cy40000y9h6lftwhcie
cmrknuslh034x4hle52ouxrh3	edge 20 pro	cmrknujz5000r4hleshjq47jw	2026-07-14 13:02:04.613	2026-07-14 13:02:04.613	cmrkb3cy40000y9h6lftwhcie
cmrknuslp034z4hlepmsig8d8	iphone 11	cmrknujzo000w4hlesj7fng18	2026-07-14 13:02:04.621	2026-07-14 13:02:04.621	cmrkb3cy40000y9h6lftwhcie
cmrknuslw03514hleq387qox0	13 promax	cmrknujzo000w4hlesj7fng18	2026-07-14 13:02:04.628	2026-07-14 13:02:04.628	cmrkb3cy40000y9h6lftwhcie
cmrknusm403534hleg0ak87ub	iphone 13 promax	cmrknujzo000w4hlesj7fng18	2026-07-14 13:02:04.636	2026-07-14 13:02:04.636	cmrkb3cy40000y9h6lftwhcie
cmrknusma03554hle4uw4c3e2	moto g54	cmrknujz5000r4hleshjq47jw	2026-07-14 13:02:04.642	2026-07-14 13:02:04.642	cmrkb3cy40000y9h6lftwhcie
cmrknusmh03574hleaoy1wipc	iphone 6s	cmrknujzo000w4hlesj7fng18	2026-07-14 13:02:04.649	2026-07-14 13:02:04.649	cmrkb3cy40000y9h6lftwhcie
cmrknusmp03594hleu7is34yw	iphone 7	cmrknujzo000w4hlesj7fng18	2026-07-14 13:02:04.657	2026-07-14 13:02:04.657	cmrkb3cy40000y9h6lftwhcie
cmrknusmw035b4hletixi9cgt	iphone 8	cmrknujzo000w4hlesj7fng18	2026-07-14 13:02:04.664	2026-07-14 13:02:04.664	cmrkb3cy40000y9h6lftwhcie
cmrknusn2035d4hlet253fmsf	iphone x	cmrknujzo000w4hlesj7fng18	2026-07-14 13:02:04.671	2026-07-14 13:02:04.671	cmrkb3cy40000y9h6lftwhcie
cmrknusn8035f4hle12ofknao	iphone xs	cmrknujzo000w4hlesj7fng18	2026-07-14 13:02:04.676	2026-07-14 13:02:04.676	cmrkb3cy40000y9h6lftwhcie
cmrknusnf035h4hleqjp3o4de	iphone xs max	cmrknujzo000w4hlesj7fng18	2026-07-14 13:02:04.683	2026-07-14 13:02:04.683	cmrkb3cy40000y9h6lftwhcie
cmrknusnn035j4hlemqflbimg	iphone se 2016	cmrknujzo000w4hlesj7fng18	2026-07-14 13:02:04.691	2026-07-14 13:02:04.691	cmrkb3cy40000y9h6lftwhcie
cmrknusnt035l4hle78ull8hq	iphone se 2020/2022	cmrknujzo000w4hlesj7fng18	2026-07-14 13:02:04.697	2026-07-14 13:02:04.697	cmrkb3cy40000y9h6lftwhcie
cmrknuso0035n4hleolzhey0f	iphone 11 pro	cmrknujzo000w4hlesj7fng18	2026-07-14 13:02:04.704	2026-07-14 13:02:04.704	cmrkb3cy40000y9h6lftwhcie
cmrknuso6035p4hleg1f5s7qh	iphone 11 pro max	cmrknujzo000w4hlesj7fng18	2026-07-14 13:02:04.71	2026-07-14 13:02:04.71	cmrkb3cy40000y9h6lftwhcie
cmrknusoc035r4hleikj33a89	iphone 12	cmrknujzo000w4hlesj7fng18	2026-07-14 13:02:04.717	2026-07-14 13:02:04.717	cmrkb3cy40000y9h6lftwhcie
cmrknusoj035t4hleeogpfz30	iphone 12 mini	cmrknujzo000w4hlesj7fng18	2026-07-14 13:02:04.723	2026-07-14 13:02:04.723	cmrkb3cy40000y9h6lftwhcie
cmrknusop035v4hley486zzxx	iphone 12 pro	cmrknujzo000w4hlesj7fng18	2026-07-14 13:02:04.729	2026-07-14 13:02:04.729	cmrkb3cy40000y9h6lftwhcie
cmrknusow035x4hle8qsksmw6	iphone 13 pro	cmrknujzo000w4hlesj7fng18	2026-07-14 13:02:04.736	2026-07-14 13:02:04.736	cmrkb3cy40000y9h6lftwhcie
cmrknusp2035z4hlez222qrow	iphone 15 pro max	cmrknujzo000w4hlesj7fng18	2026-07-14 13:02:04.743	2026-07-14 13:02:04.743	cmrkb3cy40000y9h6lftwhcie
cmrknusp803614hlevjl6o0vn	samsung s10	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:04.749	2026-07-14 13:02:04.749	cmrkb3cy40000y9h6lftwhcie
cmrknuspf03634hleilvfe3ei	samsung s21 ultra	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:04.755	2026-07-14 13:02:04.755	cmrkb3cy40000y9h6lftwhcie
cmrknuspm03654hleoyv47b5y	samsung s23 fe	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:04.762	2026-07-14 13:02:04.762	cmrkb3cy40000y9h6lftwhcie
cmrknusps03674hle1xby3sxk	samsung s24 5g	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:04.768	2026-07-14 13:02:04.768	cmrkb3cy40000y9h6lftwhcie
cmrknuspy03694hleoblpugdm	samsung s24 fe	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:04.774	2026-07-14 13:02:04.774	cmrkb3cy40000y9h6lftwhcie
cmrknusq4036b4hleg1l3l7hs	samsung a26	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:04.78	2026-07-14 13:02:04.78	cmrkb3cy40000y9h6lftwhcie
cmrknusqb036d4hlea4u93slk	samsung m01	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:04.787	2026-07-14 13:02:04.787	cmrkb3cy40000y9h6lftwhcie
cmrknusqh036f4hleiqygbn34	samsung m31	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:04.793	2026-07-14 13:02:04.793	cmrkb3cy40000y9h6lftwhcie
cmrknusqn036h4hlet0g2auq7	samsung m32	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:04.8	2026-07-14 13:02:04.8	cmrkb3cy40000y9h6lftwhcie
cmrknusqu036j4hleuajdop36	samsung note 5 5g	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:04.806	2026-07-14 13:02:04.806	cmrkb3cy40000y9h6lftwhcie
cmrknusr0036l4hleezwyyicq	samsung note 8	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:04.812	2026-07-14 13:02:04.812	cmrkb3cy40000y9h6lftwhcie
cmrknusr7036n4hleswn41n1q	samsung note 8 pro	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:04.819	2026-07-14 13:02:04.819	cmrkb3cy40000y9h6lftwhcie
cmrknusrd036p4hlembnt5b04	samsung note 8t	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:04.825	2026-07-14 13:02:04.825	cmrkb3cy40000y9h6lftwhcie
cmrknusrj036r4hledswso0c4	samsung note 10 plus	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:04.832	2026-07-14 13:02:04.832	cmrkb3cy40000y9h6lftwhcie
cmrknusrq036t4hle0iv5y0s9	samsung note10 pro max	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:04.838	2026-07-14 13:02:04.838	cmrkb3cy40000y9h6lftwhcie
cmrknusrw036v4hle6f1q2krx	samsung note 11 4g	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:04.845	2026-07-14 13:02:04.845	cmrkb3cy40000y9h6lftwhcie
cmrknuss3036x4hlelrl3bhex	samsung note 11s	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:04.851	2026-07-14 13:02:04.851	cmrkb3cy40000y9h6lftwhcie
cmrknussa036z4hlef4q2ewac	samsung note 11 pro plus	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:04.858	2026-07-14 13:02:04.858	cmrkb3cy40000y9h6lftwhcie
cmrknussg03714hlezpyagt86	samsung note 12 4g	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:04.864	2026-07-14 13:02:04.864	cmrkb3cy40000y9h6lftwhcie
cmrknussn03734hle6r8s27ea	samsung note 12 pro 4g	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:04.871	2026-07-14 13:02:04.871	cmrkb3cy40000y9h6lftwhcie
cmrknusst03754hle3kxsdkwa	samsung note 12 pro 5g	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:04.877	2026-07-14 13:02:04.877	cmrkb3cy40000y9h6lftwhcie
cmrknussz03774hles82ky7yf	samsung note 12 pro plus	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:04.883	2026-07-14 13:02:04.883	cmrkb3cy40000y9h6lftwhcie
cmrknust603794hlexsqt4q5q	samsung note 12 s	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:04.89	2026-07-14 13:02:04.89	cmrkb3cy40000y9h6lftwhcie
cmrknustc037b4hlebf3y3nn3	samsung note 12 5g	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:04.896	2026-07-14 13:02:04.896	cmrkb3cy40000y9h6lftwhcie
cmrknusti037d4hlem8kn5scy	samsung note 13 pro	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:04.903	2026-07-14 13:02:04.903	cmrkb3cy40000y9h6lftwhcie
cmrknustp037f4hlejrdfo4rn	samsung note 13 pro plus	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:04.909	2026-07-14 13:02:04.909	cmrkb3cy40000y9h6lftwhcie
cmrknustw037h4hleogbkkzmu	samsung note 14	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:04.916	2026-07-14 13:02:04.916	cmrkb3cy40000y9h6lftwhcie
cmrknusu3037j4hle70fsd8y5	samsung note 14 4g	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:04.923	2026-07-14 13:02:04.923	cmrkb3cy40000y9h6lftwhcie
cmrknusua037l4hled6lnu3dn	samsung note 14 pro 5g	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:04.93	2026-07-14 13:02:04.93	cmrkb3cy40000y9h6lftwhcie
cmrknusuh037n4hle81lq16hg	samsung note 14 pro plus 5g	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:04.938	2026-07-14 13:02:04.938	cmrkb3cy40000y9h6lftwhcie
cmrknusun037p4hle3s5b6iqe	samsung galaxy tab t515	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:04.944	2026-07-14 13:02:04.944	cmrkb3cy40000y9h6lftwhcie
cmrknusuv037r4hlenwircxkm	samsung galaxy tab t865	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:04.951	2026-07-14 13:02:04.951	cmrkb3cy40000y9h6lftwhcie
cmrknusv2037t4hlefz4zvbe8	samsung galaxy tab a t295	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:04.958	2026-07-14 13:02:04.958	cmrkb3cy40000y9h6lftwhcie
cmrknusv9037v4hlehq251mx1	samsung note 10 pro max	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:04.966	2026-07-14 13:02:04.966	cmrkb3cy40000y9h6lftwhcie
cmrknusvh037x4hleu56m0lj2	mi 12x	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:04.973	2026-07-14 13:02:04.973	cmrkb3cy40000y9h6lftwhcie
cmrknusvo037z4hleai24ag2r	mi 14pro	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:04.98	2026-07-14 13:02:04.98	cmrkb3cy40000y9h6lftwhcie
cmrknusvv03814hlemw0m7zj2	mi 14t pro	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:04.987	2026-07-14 13:02:04.987	cmrkb3cy40000y9h6lftwhcie
cmrknusw103834hle28m0hv9t	redmi note15 5g	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:04.993	2026-07-14 13:02:04.993	cmrkb3cy40000y9h6lftwhcie
cmrknusw803854hlertklbqpd	POCO F6	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:05	2026-07-14 13:02:05	cmrkb3cy40000y9h6lftwhcie
cmrknuswf03874hlem6077xbd	iphone 12 pro max	cmrknujzo000w4hlesj7fng18	2026-07-14 13:02:05.007	2026-07-14 13:02:05.007	cmrkb3cy40000y9h6lftwhcie
cmrknuswm03894hle861luy2i	iphone 13	cmrknujzo000w4hlesj7fng18	2026-07-14 13:02:05.015	2026-07-14 13:02:05.015	cmrkb3cy40000y9h6lftwhcie
cmrknuswu038b4hleatfopbt3	iphone 16 pro max	cmrknujzo000w4hlesj7fng18	2026-07-14 13:02:05.022	2026-07-14 13:02:05.022	cmrkb3cy40000y9h6lftwhcie
cmrknusx0038d4hleov6tmfby	samsung s7 edge	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:05.029	2026-07-14 13:02:05.029	cmrkb3cy40000y9h6lftwhcie
cmrknusx8038f4hleizavtaji	samsung  s8	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:05.036	2026-07-14 13:02:05.036	cmrkb3cy40000y9h6lftwhcie
cmrknusxe038h4hle4ta0f80o	samsung  s8 plus	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:05.043	2026-07-14 13:02:05.043	cmrkb3cy40000y9h6lftwhcie
cmrknusxk038j4hle6jj6osi9	samsung a54 5g	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:05.049	2026-07-14 13:02:05.049	cmrkb3cy40000y9h6lftwhcie
cmrknusxr038l4hlewlqsay4j	samsung galaxy j7 2016	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:05.055	2026-07-14 13:02:05.055	cmrkb3cy40000y9h6lftwhcie
cmrknusxy038n4hle157g9ifu	xiaomi mi 12 5g	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:05.062	2026-07-14 13:02:05.062	cmrkb3cy40000y9h6lftwhcie
cmrknusy5038p4hle946qa1v3	xiaomi mi 13t 5g	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:05.069	2026-07-14 13:02:05.069	cmrkb3cy40000y9h6lftwhcie
cmrknusyb038r4hle088k0w40	redmi note 11 4g	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:05.076	2026-07-14 13:02:05.076	cmrkb3cy40000y9h6lftwhcie
cmrknusyh038t4hlecmwekduf	motorola g60	cmrknujz5000r4hleshjq47jw	2026-07-14 13:02:05.081	2026-07-14 13:02:05.081	cmrkb3cy40000y9h6lftwhcie
cmrknusyo038v4hlesf7ff2hm	motorola one hyper	cmrknujz5000r4hleshjq47jw	2026-07-14 13:02:05.088	2026-07-14 13:02:05.088	cmrkb3cy40000y9h6lftwhcie
cmrknusyu038x4hle19cwnvgc	poco m7 pro	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:05.095	2026-07-14 13:02:05.095	cmrkb3cy40000y9h6lftwhcie
cmrknusz1038z4hleimlmm6jz	Sam S20 ultra	cmrknuk0b00134hleluzcrkjn	2026-07-14 13:02:05.102	2026-07-14 13:02:05.102	cmrkb3cy40000y9h6lftwhcie
cmrknusz803914hle29zofxbs	Moto g51	cmrknujz5000r4hleshjq47jw	2026-07-14 13:02:05.108	2026-07-14 13:02:05.108	cmrkb3cy40000y9h6lftwhcie
cmrknuszf03934hlekzcrisbt	Nokia 8	cmrknuk1s001i4hleqifj4gnr	2026-07-14 13:02:05.115	2026-07-14 13:02:05.115	cmrkb3cy40000y9h6lftwhcie
cmrknuszl03954hlenc27v3h7	Y6 2019	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:05.121	2026-07-14 13:02:05.121	cmrkb3cy40000y9h6lftwhcie
cmrknuszr03974hle47hqgd17	Poco pad7	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:05.128	2026-07-14 13:02:05.128	cmrkb3cyo0001y9h6bozaifdg
cmrknuszy03994hlesfi8rv6i	K40 gaming	cmrknujzv000y4hle1u0ywsym	2026-07-14 13:02:05.134	2026-07-14 13:02:05.134	cmrkb3cy40000y9h6lftwhcie
cmrknut04039b4hlemk72k60t	Moto g84	cmrknujz5000r4hleshjq47jw	2026-07-14 13:02:05.14	2026-07-14 13:02:05.14	cmrkb3cy40000y9h6lftwhcie
cmrknut0a039d4hles56d0cdt	Nova 7i	cmrknujzi000u4hle2av7btwx	2026-07-14 13:02:05.146	2026-07-14 13:02:05.146	cmrkb3cy40000y9h6lftwhcie
cmrknut0g039f4hle677spnqb	Moto g30	cmrknujz5000r4hleshjq47jw	2026-07-14 13:02:05.152	2026-07-14 13:02:05.152	cmrkb3cy40000y9h6lftwhcie
\.


--
-- Data for Name: device_types; Type: TABLE DATA; Schema: public; Owner: bartar_user
--

COPY public.device_types (id, name, "createdAt", "updatedAt") FROM stdin;
cmrkb3cy40000y9h6lftwhcie	موبایل	2026-07-14 07:04:49.229	2026-07-14 07:04:49.229
cmrkb3cyo0001y9h6bozaifdg	تبلت	2026-07-14 07:04:49.249	2026-07-14 07:04:49.249
cmrkb3cyv0002y9h62ukua81l	لپ‌تاپ	2026-07-14 07:04:49.255	2026-07-14 07:04:49.255
cmrknujwg00004hlezsabsciv	هندزفری بی سیم	2026-07-14 13:01:53.344	2026-07-14 13:01:53.344
cmrknujwq00014hlesyp4q2hj	کنسول بازی	2026-07-14 13:01:53.354	2026-07-14 13:01:53.354
cmrknujws00024hle61bdckim	هندزفری بلوتوثی	2026-07-14 13:01:53.357	2026-07-14 13:01:53.357
cmrknujwv00034hlebaerivwe	پمپ باد	2026-07-14 13:01:53.36	2026-07-14 13:01:53.36
cmrknujwz00044hle5lxikvcu	ساعت	2026-07-14 13:01:53.363	2026-07-14 13:01:53.363
cmrknujx200054hlexj2ts9xq	انروید باکس	2026-07-14 13:01:53.366	2026-07-14 13:01:53.366
cmrknujx800074hlexsapxr4z	آل این وان	2026-07-14 13:01:53.372	2026-07-14 13:01:53.372
cmrknujxc00084hleb13o6z4a	جارو رباتیک	2026-07-14 13:01:53.376	2026-07-14 13:01:53.376
cmrknujxg00094hleveoq8smb	کیس	2026-07-14 13:01:53.38	2026-07-14 13:01:53.38
cmrknujxj000a4hledariu2zy	دسته بازی	2026-07-14 13:01:53.384	2026-07-14 13:01:53.384
cmrknujxm000b4hle4o2fwrvs	لپ تاپ	2026-07-14 13:01:53.386	2026-07-14 13:01:53.386
cmrknujxr000d4hlevkgzk27o	مودم	2026-07-14 13:01:53.391	2026-07-14 13:01:53.391
cmrknujxu000e4hle1dgnvong	مانیتور	2026-07-14 13:01:53.395	2026-07-14 13:01:53.395
cmrknujxx000f4hle4jp78rc5	ایرپاد	2026-07-14 13:01:53.398	2026-07-14 13:01:53.398
cmrknujy0000g4hleg9xefyth	تلویزیون	2026-07-14 13:01:53.401	2026-07-14 13:01:53.401
\.


--
-- Data for Name: devices; Type: TABLE DATA; Schema: public; Owner: bartar_user
--

COPY public.devices (id, "brandId", "modelId", serial, imei, "createdAt", "updatedAt", "deletedAt") FROM stdin;
cmrkbazc80005mneop7ubdxxn	cmrkbazbx0001mneo2r1y2f90	cmrkbazc30003mneojccqn9zn	\N	\N	2026-07-14 07:10:44.84	2026-07-14 07:10:44.84	\N
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: bartar_user
--

COPY public.notifications (id, "userId", title, message, "isRead", type, "createdAt") FROM stdin;
\.


--
-- Data for Name: part_prices; Type: TABLE DATA; Schema: public; Owner: bartar_user
--

COPY public.part_prices (id, "modelId", "partId", quality, "buyPrice", "sellPrice", "needsReview", notes, "createdAt", "updatedAt") FROM stdin;
cmrkbu7w7000tv0qqsobj4li3	cmrkbazc30003mneojccqn9zn	cmrkbsj4y0000v0qqw5o886a9	ORIGINAL	48000000	62400000	t	\N	2026-07-14 07:25:42.391	2026-07-14 07:25:42.391
cmrkbyflf001yv0qqvbaahc3u	cmrkbxs700015v0qqtfqefy5a	cmrkbsj4y0000v0qqw5o886a9	ORIGINAL	6000000	7800000	f	\N	2026-07-14 07:28:58.994	2026-07-14 07:52:27.021
cmrknut2x039p4hlek2d686if	cmrknuowk01xn4hleeayo14lf	cmrknut1e039j4hleuqvcm4l6	ORIGINAL	\N	1980000	f	\N	2026-07-14 13:02:05.241	2026-07-14 13:02:05.241
cmrknut3g039t4hle552nzrkk	cmrknuowk01xn4hleeayo14lf	cmrknut1e039j4hleuqvcm4l6	HIGH_COPY	\N	1460000	f	\N	2026-07-14 13:02:05.26	2026-07-14 13:02:05.26
cmrknut3t039x4hlehi4tei6b	cmrknuowk01xn4hleeayo14lf	cmrknut1e039j4hleuqvcm4l6	COPY	\N	550000	f	\N	2026-07-14 13:02:05.274	2026-07-14 13:02:05.274
cmrknut4703a14hle4iz61iqq	cmrknurun02wx4hlefzl620dj	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	3280000	f	\N	2026-07-14 13:02:05.287	2026-07-14 13:02:05.287
cmrknut4j03a54hlekbe3nslj	cmrknurun02wx4hlefzl620dj	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	2300000	f	\N	2026-07-14 13:02:05.299	2026-07-14 13:02:05.299
cmrknut4w03a94hle6zd0lu9b	cmrknurun02wx4hlefzl620dj	cmrknut0y039h4hlekczcvqvm	COPY	\N	1700000	f	\N	2026-07-14 13:02:05.312	2026-07-14 13:02:05.312
cmrknut5803ad4hlecplvczeh	cmrknusde032j4hlenxdh2yqj	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	12000000	f	\N	2026-07-14 13:02:05.324	2026-07-14 13:02:05.324
cmrknut5k03ah4hlell30r8hl	cmrknuoq001s94hleyl59xkq5	cmrknut1e039j4hleuqvcm4l6	ORIGINAL	\N	1980000	f	\N	2026-07-14 13:02:05.336	2026-07-14 13:02:05.336
cmrknut5v03al4hlebo8wslul	cmrknuoq001s94hleyl59xkq5	cmrknut1e039j4hleuqvcm4l6	HIGH_COPY	\N	1200000	f	\N	2026-07-14 13:02:05.347	2026-07-14 13:02:05.347
cmrknut6603ap4hle6aaz6eou	cmrknuoq001s94hleyl59xkq5	cmrknut1e039j4hleuqvcm4l6	COPY	\N	600	f	\N	2026-07-14 13:02:05.359	2026-07-14 13:02:05.359
cmrknut6i03at4hle9eym4pmg	cmrknuog001kb4hle3xbh9az9	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	4320000	f	\N	2026-07-14 13:02:05.37	2026-07-14 13:02:05.37
cmrknut6s03ax4hlexmdhlw32	cmrknuog001kb4hle3xbh9az9	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	3750000	f	\N	2026-07-14 13:02:05.381	2026-07-14 13:02:05.381
cmrknut7403b14hledqa2xlh0	cmrknuog001kb4hle3xbh9az9	cmrkbbzjk000amneoowf62wmn	COPY	\N	2900000	f	\N	2026-07-14 13:02:05.392	2026-07-14 13:02:05.392
cmrknut7e03b54hleftxemuhh	cmrknuoyb01yx4hlepbqolnr3	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	13850000	f	\N	2026-07-14 13:02:05.403	2026-07-14 13:02:05.403
cmrknut7q03b94hlebnyu7i6k	cmrknuoyb01yx4hlepbqolnr3	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	11300000	f	\N	2026-07-14 13:02:05.414	2026-07-14 13:02:05.414
cmrknut8103bd4hle7dx28kra	cmrknuoyb01yx4hlepbqolnr3	cmrknut0y039h4hlekczcvqvm	COPY	\N	2900000	f	\N	2026-07-14 13:02:05.425	2026-07-14 13:02:05.425
cmrknut8d03bh4hle182204h7	cmrknuk45002b4hle2tooy7xy	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	5980000	f	\N	2026-07-14 13:02:05.437	2026-07-14 13:02:05.437
cmrknut8o03bl4hlefqknvvs9	cmrknuk45002b4hle2tooy7xy	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	3350000	f	\N	2026-07-14 13:02:05.448	2026-07-14 13:02:05.448
cmrknut8z03bp4hleip3nuy17	cmrknuk45002b4hle2tooy7xy	cmrknut0y039h4hlekczcvqvm	COPY	\N	1500000	f	\N	2026-07-14 13:02:05.459	2026-07-14 13:02:05.459
cmrknut9b03bt4hle00afhpce	cmrknuk45002b4hle2tooy7xy	cmrknut16039i4hlen5tdjud5	ORIGINAL	\N	500000	f	\N	2026-07-14 13:02:05.471	2026-07-14 13:02:05.471
cmrknut9m03bx4hlevy51dvrw	cmrknuk45002b4hle2tooy7xy	cmrknut16039i4hlen5tdjud5	HIGH_COPY	\N	850000	f	\N	2026-07-14 13:02:05.482	2026-07-14 13:02:05.482
cmrknut9w03c14hle87nbel2p	cmrknuk45002b4hle2tooy7xy	cmrknut16039i4hlen5tdjud5	COPY	\N	1470000	f	\N	2026-07-14 13:02:05.493	2026-07-14 13:02:05.493
cmrknuta803c54hle0s9t6y2f	cmrknuorx01tj4hlebwnvqk6a	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	2440000	f	\N	2026-07-14 13:02:05.504	2026-07-14 13:02:05.504
cmrknutaj03c94hle00bfsv1e	cmrknuorx01tj4hlebwnvqk6a	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	1780000	f	\N	2026-07-14 13:02:05.516	2026-07-14 13:02:05.516
cmrknutav03cd4hle334mdlzo	cmrknuorx01tj4hlebwnvqk6a	cmrkbbzjk000amneoowf62wmn	COPY	\N	1100000	f	\N	2026-07-14 13:02:05.527	2026-07-14 13:02:05.527
cmrknutb603ch4hleifla048x	cmrknuklm00at4hletkkael85	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	9880000	f	\N	2026-07-14 13:02:05.538	2026-07-14 13:02:05.538
cmrknutbh03cl4hle0wm8mnez	cmrknuklm00at4hletkkael85	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	7500000	f	\N	2026-07-14 13:02:05.55	2026-07-14 13:02:05.55
cmrknutbt03cp4hleyprdi4jn	cmrknuklm00at4hletkkael85	cmrknut0y039h4hlekczcvqvm	COPY	\N	2900000	f	\N	2026-07-14 13:02:05.561	2026-07-14 13:02:05.561
cmrknutc503ct4hlejawpahev	cmrknuos101tn4hle2go8iozz	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	3820000	f	\N	2026-07-14 13:02:05.573	2026-07-14 13:02:05.573
cmrknutcg03cx4hle3v2xhhrp	cmrknuos101tn4hle2go8iozz	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	2980000	f	\N	2026-07-14 13:02:05.584	2026-07-14 13:02:05.584
cmrknutcr03d14hle4pumms74	cmrknuos101tn4hle2go8iozz	cmrkbbzjk000amneoowf62wmn	COPY	\N	2500000	f	\N	2026-07-14 13:02:05.595	2026-07-14 13:02:05.595
cmrknutd203d54hlejjgmy6ck	cmrknuma100vr4hle06yrtrzv	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	3980000	f	\N	2026-07-14 13:02:05.606	2026-07-14 13:02:05.606
cmrknutdd03d94hlemlf1ng10	cmrknuma100vr4hle06yrtrzv	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	2560000	f	\N	2026-07-14 13:02:05.617	2026-07-14 13:02:05.617
cmrknutdn03dd4hlek96dlwh7	cmrknuma100vr4hle06yrtrzv	cmrknut0y039h4hlekczcvqvm	COPY	\N	1400000	f	\N	2026-07-14 13:02:05.628	2026-07-14 13:02:05.628
cmrknutdz03dh4hlecs0r73z2	cmrknurtf02wl4hle9qhocufy	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	3950000	f	\N	2026-07-14 13:02:05.639	2026-07-14 13:02:05.639
cmrknutea03dl4hleen2mroes	cmrknurtf02wl4hle9qhocufy	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	2880000	f	\N	2026-07-14 13:02:05.65	2026-07-14 13:02:05.65
cmrknutel03dp4hlekkimppk3	cmrknurtf02wl4hle9qhocufy	cmrkbbzjk000amneoowf62wmn	COPY	\N	2500000	f	\N	2026-07-14 13:02:05.662	2026-07-14 13:02:05.662
cmrknutew03dt4hlenl77usy6	cmrknuqre02kf4hlefzxppos4	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	15380000	f	\N	2026-07-14 13:02:05.672	2026-07-14 13:02:05.672
cmrknutf703dx4hle7pl3qqrl	cmrknuqre02kf4hlefzxppos4	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	12400000	f	\N	2026-07-14 13:02:05.683	2026-07-14 13:02:05.683
cmrknutfh03e14hleht596wbk	cmrknuqre02kf4hlefzxppos4	cmrknut0y039h4hlekczcvqvm	COPY	\N	2800000	f	\N	2026-07-14 13:02:05.693	2026-07-14 13:02:05.693
cmrknutft03e54hle5j4x2nfs	cmrknuo7p01g74hle1tay622j	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	4480000	f	\N	2026-07-14 13:02:05.705	2026-07-14 13:02:05.705
cmrknutg303e94hlen8iqb25e	cmrknuo7p01g74hle1tay622j	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	2450000	f	\N	2026-07-14 13:02:05.715	2026-07-14 13:02:05.715
cmrknutgd03ed4hlemohhncu7	cmrknuo7p01g74hle1tay622j	cmrknut0y039h4hlekczcvqvm	COPY	\N	1800000	f	\N	2026-07-14 13:02:05.725	2026-07-14 13:02:05.725
cmrknutgo03eh4hlekc4lusyv	cmrknunwm01c74hlesrwvz511	cmrknut1e039j4hleuqvcm4l6	ORIGINAL	\N	1950000	f	\N	2026-07-14 13:02:05.736	2026-07-14 13:02:05.736
cmrknutgy03el4hle8onfosma	cmrknunwm01c74hlesrwvz511	cmrknut1e039j4hleuqvcm4l6	HIGH_COPY	\N	1540000	f	\N	2026-07-14 13:02:05.746	2026-07-14 13:02:05.746
cmrknuth903ep4hleq9c4v8qo	cmrknunwm01c74hlesrwvz511	cmrknut1e039j4hleuqvcm4l6	COPY	\N	900000	f	\N	2026-07-14 13:02:05.758	2026-07-14 13:02:05.758
cmrknuthk03et4hle90dxui1w	cmrknus0l02yn4hlezo2m40jx	cmrknut1e039j4hleuqvcm4l6	HIGH_COPY	\N	1350000	f	\N	2026-07-14 13:02:05.768	2026-07-14 13:02:05.768
cmrknuthu03ex4hlee3yi609g	cmrknus0l02yn4hlezo2m40jx	cmrknut1e039j4hleuqvcm4l6	COPY	\N	500000	f	\N	2026-07-14 13:02:05.778	2026-07-14 13:02:05.778
cmrknuti503f14hleipebg80d	cmrknupck02634hlegn9w2wy1	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	2980000	f	\N	2026-07-14 13:02:05.789	2026-07-14 13:02:05.789
cmrknutig03f54hlegov6qmop	cmrknupck02634hlegn9w2wy1	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	2200000	f	\N	2026-07-14 13:02:05.8	2026-07-14 13:02:05.8
cmrknutiq03f94hlee2tyh0om	cmrknupck02634hlegn9w2wy1	cmrkbbzjk000amneoowf62wmn	COPY	\N	1600000	f	\N	2026-07-14 13:02:05.811	2026-07-14 13:02:05.811
cmrknutj103fd4hle7n6op0uq	cmrknupdv026f4hlexbzeua3g	cmrknut1e039j4hleuqvcm4l6	ORIGINAL	\N	1900000	f	\N	2026-07-14 13:02:05.821	2026-07-14 13:02:05.821
cmrknutjb03fh4hlep7g4268q	cmrknupdv026f4hlexbzeua3g	cmrknut1e039j4hleuqvcm4l6	HIGH_COPY	\N	1250000	f	\N	2026-07-14 13:02:05.831	2026-07-14 13:02:05.831
cmrknutjl03fl4hleioo0bw43	cmrknupdv026f4hlexbzeua3g	cmrknut1e039j4hleuqvcm4l6	COPY	\N	500	f	\N	2026-07-14 13:02:05.842	2026-07-14 13:02:05.842
cmrknutjw03fp4hleixqwmgvt	cmrknuslp034z4hlepmsig8d8	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	4790000	f	\N	2026-07-14 13:02:05.852	2026-07-14 13:02:05.852
cmrknutk603ft4hlefvzo1bas	cmrknuslp034z4hlepmsig8d8	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	3550000	f	\N	2026-07-14 13:02:05.862	2026-07-14 13:02:05.862
cmrknutkh03fx4hlew9jeafp5	cmrknuslp034z4hlepmsig8d8	cmrkbbzjk000amneoowf62wmn	COPY	\N	2500000	f	\N	2026-07-14 13:02:05.873	2026-07-14 13:02:05.873
cmrknutkr03g14hle3p7s2nh0	cmrknuk9m00514hleychr4spm	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	4580000	f	\N	2026-07-14 13:02:05.883	2026-07-14 13:02:05.883
cmrknutl103g54hleiqwiruqw	cmrknuk9m00514hleychr4spm	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	3250000	f	\N	2026-07-14 13:02:05.893	2026-07-14 13:02:05.893
cmrknutld03g94hle4qkwuffi	cmrknuk9m00514hleychr4spm	cmrknut0y039h4hlekczcvqvm	COPY	\N	1800000	f	\N	2026-07-14 13:02:05.905	2026-07-14 13:02:05.905
cmrknutlo03gd4hlexvip4u6y	cmrknusma03554hle4uw4c3e2	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	4850000	f	\N	2026-07-14 13:02:05.916	2026-07-14 13:02:05.916
cmrknutm003gh4hle5xnigf3o	cmrknusma03554hle4uw4c3e2	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	3220000	f	\N	2026-07-14 13:02:05.928	2026-07-14 13:02:05.928
cmrknutmb03gl4hlejrhnugtv	cmrknusma03554hle4uw4c3e2	cmrkbbzjk000amneoowf62wmn	COPY	\N	2800000	f	\N	2026-07-14 13:02:05.939	2026-07-14 13:02:05.939
cmrknutmm03gp4hles37agfi4	cmrknus4402zp4hlem8rkfrdy	cmrknut1e039j4hleuqvcm4l6	ORIGINAL	\N	1210000	f	\N	2026-07-14 13:02:05.951	2026-07-14 13:02:05.951
cmrknutmy03gt4hleofu5r07p	cmrknus4402zp4hlem8rkfrdy	cmrknut1e039j4hleuqvcm4l6	HIGH_COPY	\N	890000	f	\N	2026-07-14 13:02:05.962	2026-07-14 13:02:05.962
cmrknutn903gx4hle79s8dou4	cmrknus4402zp4hlem8rkfrdy	cmrknut1e039j4hleuqvcm4l6	COPY	\N	500000	f	\N	2026-07-14 13:02:05.973	2026-07-14 13:02:05.973
cmrknutnk03h14hlerzdbk0b3	cmrknus4402zp4hlem8rkfrdy	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	4480000	f	\N	2026-07-14 13:02:05.984	2026-07-14 13:02:05.984
cmrknutnu03h54hle5icsmunt	cmrknus4402zp4hlem8rkfrdy	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	3250000	f	\N	2026-07-14 13:02:05.994	2026-07-14 13:02:05.994
cmrknuto603h94hle61vjcwc0	cmrknus4402zp4hlem8rkfrdy	cmrknut0y039h4hlekczcvqvm	COPY	\N	1900000	f	\N	2026-07-14 13:02:06.006	2026-07-14 13:02:06.006
cmrknutoh03hd4hleb882h3lr	cmrknuorx01tj4hlebwnvqk6a	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	3920000	f	\N	2026-07-14 13:02:06.017	2026-07-14 13:02:06.017
cmrknutor03hh4hlenfgunkex	cmrknuorx01tj4hlebwnvqk6a	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	2580000	f	\N	2026-07-14 13:02:06.028	2026-07-14 13:02:06.028
cmrknutp303hl4hle9rewx4p4	cmrknuorx01tj4hlebwnvqk6a	cmrknut0y039h4hlekczcvqvm	COPY	\N	1800000	f	\N	2026-07-14 13:02:06.039	2026-07-14 13:02:06.039
cmrknutpd03hp4hleif5pm6s4	cmrknuljf00ot4hledyrnjask	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	4200000	f	\N	2026-07-14 13:02:06.049	2026-07-14 13:02:06.049
cmrknutpo03ht4hleucr6pu16	cmrknuljf00ot4hledyrnjask	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	2950000	f	\N	2026-07-14 13:02:06.06	2026-07-14 13:02:06.06
cmrknutpy03hx4hle6281eeg3	cmrknuljf00ot4hledyrnjask	cmrknut0y039h4hlekczcvqvm	COPY	\N	1950000	f	\N	2026-07-14 13:02:06.07	2026-07-14 13:02:06.07
cmrknutq803i14hlehnbrarvp	cmrknumws012f4hlenzrif5fg	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	2500000	f	\N	2026-07-14 13:02:06.08	2026-07-14 13:02:06.08
cmrknutqi03i54hle0c0l6dmg	cmrknumws012f4hlenzrif5fg	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	1800000	f	\N	2026-07-14 13:02:06.091	2026-07-14 13:02:06.091
cmrknutqs03i94hletvfqpvo2	cmrknumws012f4hlenzrif5fg	cmrkbbzjk000amneoowf62wmn	COPY	\N	1300000	f	\N	2026-07-14 13:02:06.101	2026-07-14 13:02:06.101
cmrknutr303id4hlew7uluwi1	cmrknus0l02yn4hlezo2m40jx	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	2700000	f	\N	2026-07-14 13:02:06.111	2026-07-14 13:02:06.111
cmrknutrd03ih4hleicctjk2s	cmrknus0l02yn4hlezo2m40jx	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	1700000	f	\N	2026-07-14 13:02:06.121	2026-07-14 13:02:06.121
cmrknutrn03il4hlexxki0ph4	cmrknus0l02yn4hlezo2m40jx	cmrkbbzjk000amneoowf62wmn	COPY	\N	1100000	f	\N	2026-07-14 13:02:06.131	2026-07-14 13:02:06.131
cmrknutrx03ip4hlenjc9qzmq	cmrknuqp902jr4hlej33uq7e6	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	2100000	f	\N	2026-07-14 13:02:06.142	2026-07-14 13:02:06.142
cmrknuts703it4hleqkawhmuz	cmrknuqp902jr4hlej33uq7e6	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	1500000	f	\N	2026-07-14 13:02:06.151	2026-07-14 13:02:06.151
cmrknutsi03ix4hlefywe1yuh	cmrknuqp902jr4hlej33uq7e6	cmrkbbzjk000amneoowf62wmn	COPY	\N	900000	f	\N	2026-07-14 13:02:06.162	2026-07-14 13:02:06.162
cmrknutss03j14hle5uoabenc	cmrknup6z024j4hlen4lnzqxc	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	2200000	f	\N	2026-07-14 13:02:06.172	2026-07-14 13:02:06.172
cmrknutt203j54hle24uw05j0	cmrknup6z024j4hlen4lnzqxc	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	1600000	f	\N	2026-07-14 13:02:06.182	2026-07-14 13:02:06.182
cmrknuttc03j94hleiag26kcg	cmrknup6z024j4hlen4lnzqxc	cmrkbbzjk000amneoowf62wmn	COPY	\N	1000000	f	\N	2026-07-14 13:02:06.192	2026-07-14 13:02:06.192
cmrknuttm03jd4hle9fqi37q4	cmrknusdx032p4hled5k27zvu	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	1400000	f	دستگاه از روی ال سی دی باز میشود ریسک شکست و اجرت بیشتر	2026-07-14 13:02:06.202	2026-07-14 13:02:06.202
cmrknuttw03jh4hle6zhj689e	cmrknusdx032p4hled5k27zvu	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	900000	f	دستگاه از روی ال سی دی باز میشود ریسک شکست و اجرت بیشتر	2026-07-14 13:02:06.213	2026-07-14 13:02:06.213
cmrknutu703jl4hlept0lj2ne	cmrknusdx032p4hled5k27zvu	cmrkbbzjk000amneoowf62wmn	COPY	\N	500000	f	دستگاه از روی ال سی دی باز میشود ریسک شکست و اجرت بیشتر	2026-07-14 13:02:06.223	2026-07-14 13:02:06.223
cmrknutuh03jp4hleqdtldzme	cmrknurdz02qx4hle78n4g5hg	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	2200000	f	\N	2026-07-14 13:02:06.233	2026-07-14 13:02:06.233
cmrknutur03jt4hleqh2a5zc4	cmrknurdz02qx4hle78n4g5hg	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	1600000	f	\N	2026-07-14 13:02:06.243	2026-07-14 13:02:06.243
cmrknutv203jx4hle9nzc360q	cmrknurdz02qx4hle78n4g5hg	cmrkbbzjk000amneoowf62wmn	COPY	\N	1000000	f	\N	2026-07-14 13:02:06.254	2026-07-14 13:02:06.254
cmrknutve03k14hle9ht0mmcs	cmrknuk45002b4hle2tooy7xy	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	2600000	f	\N	2026-07-14 13:02:06.266	2026-07-14 13:02:06.266
cmrknutvp03k54hle9kitxy1l	cmrknuk45002b4hle2tooy7xy	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	1700000	f	\N	2026-07-14 13:02:06.277	2026-07-14 13:02:06.277
cmrknutw103k94hlegd8ml9pt	cmrknuk45002b4hle2tooy7xy	cmrkbbzjk000amneoowf62wmn	COPY	\N	900000	f	\N	2026-07-14 13:02:06.289	2026-07-14 13:02:06.289
cmrknutwc03kd4hleoot6qhag	cmrknukj1009x4hle6uioxq9r	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	3800000	f	\N	2026-07-14 13:02:06.3	2026-07-14 13:02:06.3
cmrknutwn03kh4hlevqbsay7f	cmrknukj1009x4hle6uioxq9r	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	2800000	f	\N	2026-07-14 13:02:06.311	2026-07-14 13:02:06.311
cmrknutwy03kl4hlezvt6n69j	cmrknukj1009x4hle6uioxq9r	cmrkbbzjk000amneoowf62wmn	COPY	\N	1800000	f	\N	2026-07-14 13:02:06.323	2026-07-14 13:02:06.323
cmrknutxa03kp4hlezi4qud05	cmrknumyz01334hleloqz20ui	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	4300000	f	\N	2026-07-14 13:02:06.334	2026-07-14 13:02:06.334
cmrknutxl03kt4hlekeleq72a	cmrknumyz01334hleloqz20ui	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	3200000	f	\N	2026-07-14 13:02:06.345	2026-07-14 13:02:06.345
cmrknutxw03kx4hletksmwgaq	cmrknumyz01334hleloqz20ui	cmrkbbzjk000amneoowf62wmn	COPY	\N	2500000	f	\N	2026-07-14 13:02:06.357	2026-07-14 13:02:06.357
cmrknuty703l14hlehlt26nyt	cmrknukid009d4hlejp5ntjfo	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	5900000	f	\N	2026-07-14 13:02:06.368	2026-07-14 13:02:06.368
cmrknutyi03l54hlerp0ch728	cmrknukid009d4hlejp5ntjfo	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	4700000	f	\N	2026-07-14 13:02:06.378	2026-07-14 13:02:06.378
cmrknutyt03l94hle1lp6brwh	cmrknukid009d4hlejp5ntjfo	cmrkbbzjk000amneoowf62wmn	COPY	\N	3500000	f	\N	2026-07-14 13:02:06.39	2026-07-14 13:02:06.39
cmrknutz403ld4hle52isgemw	cmrknukao005f4hle9fi9lqkd	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	2500000	f	\N	2026-07-14 13:02:06.4	2026-07-14 13:02:06.4
cmrknutzf03lh4hlekd4j3okc	cmrknukao005f4hle9fi9lqkd	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	1700000	f	\N	2026-07-14 13:02:06.411	2026-07-14 13:02:06.411
cmrknutzq03ll4hle6qv8y8ux	cmrknukao005f4hle9fi9lqkd	cmrkbbzjk000amneoowf62wmn	COPY	\N	1300000	f	\N	2026-07-14 13:02:06.422	2026-07-14 13:02:06.422
cmrknuu0103lp4hle8p3d17sp	cmrknuk3m00214hleqygbqv6j	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	3500000	f	\N	2026-07-14 13:02:06.434	2026-07-14 13:02:06.434
cmrknuu0d03lt4hle79k3mvp0	cmrknuk3m00214hleqygbqv6j	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	2600000	f	\N	2026-07-14 13:02:06.445	2026-07-14 13:02:06.445
cmrknuu0o03lx4hlee6aink9m	cmrknuk3m00214hleqygbqv6j	cmrkbbzjk000amneoowf62wmn	COPY	\N	1600000	f	\N	2026-07-14 13:02:06.457	2026-07-14 13:02:06.457
cmrknuu0z03m14hlenrdju61w	cmrknuk9x00554hle9um1cc7q	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	4500000	f	\N	2026-07-14 13:02:06.467	2026-07-14 13:02:06.467
cmrknuu1a03m54hlewzmfbh4k	cmrknuk9x00554hle9um1cc7q	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	3700000	f	\N	2026-07-14 13:02:06.478	2026-07-14 13:02:06.478
cmrknuu1l03m94hleyz4w9it3	cmrknuk9x00554hle9um1cc7q	cmrkbbzjk000amneoowf62wmn	COPY	\N	2600000	f	\N	2026-07-14 13:02:06.489	2026-07-14 13:02:06.489
cmrknuu1w03md4hle1rkmwbvc	cmrknuk68003b4hleloxciixq	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	1900000	f	\N	2026-07-14 13:02:06.5	2026-07-14 13:02:06.5
cmrknuu2703mh4hle2fivmmn3	cmrknuk68003b4hleloxciixq	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	1400000	f	\N	2026-07-14 13:02:06.511	2026-07-14 13:02:06.511
cmrknuu2i03ml4hlem88272wb	cmrknuk68003b4hleloxciixq	cmrkbbzjk000amneoowf62wmn	COPY	\N	1000000	f	\N	2026-07-14 13:02:06.522	2026-07-14 13:02:06.522
cmrknuu2t03mp4hleo6deh6sv	cmrknurr502vx4hle7a5jpm1p	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	1900000	f	\N	2026-07-14 13:02:06.533	2026-07-14 13:02:06.533
cmrknuu3403mt4hlev1akjzfe	cmrknurr502vx4hle7a5jpm1p	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	1400000	f	\N	2026-07-14 13:02:06.545	2026-07-14 13:02:06.545
cmrknuu3g03mx4hley95770e7	cmrknurr502vx4hle7a5jpm1p	cmrkbbzjk000amneoowf62wmn	COPY	\N	1000000	f	\N	2026-07-14 13:02:06.556	2026-07-14 13:02:06.556
cmrknuu3r03n14hlekv8z5jth	cmrknuk50002n4hlevq2b3czx	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	2100000	f	\N	2026-07-14 13:02:06.567	2026-07-14 13:02:06.567
cmrknuu4203n54hletyqd2f4s	cmrknuk50002n4hlevq2b3czx	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	1600000	f	\N	2026-07-14 13:02:06.578	2026-07-14 13:02:06.578
cmrknuu4d03n94hlefgpamdok	cmrknuk50002n4hlevq2b3czx	cmrkbbzjk000amneoowf62wmn	COPY	\N	1100000	f	\N	2026-07-14 13:02:06.589	2026-07-14 13:02:06.589
cmrknuu4o03nd4hlewzkzk1ml	cmrknuk7e003x4hleakqib6r2	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	2500000	f	\N	2026-07-14 13:02:06.6	2026-07-14 13:02:06.6
cmrknuu4z03nh4hlevxd8zy1u	cmrknuk7e003x4hleakqib6r2	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	1800000	f	\N	2026-07-14 13:02:06.611	2026-07-14 13:02:06.611
cmrknuu5a03nl4hleo7qy1eat	cmrknuk7e003x4hleakqib6r2	cmrkbbzjk000amneoowf62wmn	COPY	\N	1300000	f	\N	2026-07-14 13:02:06.622	2026-07-14 13:02:06.622
cmrknuu5l03np4hlec7ym67qx	cmrknukf5006z4hleqkmh6fuc	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	2500000	f	\N	2026-07-14 13:02:06.633	2026-07-14 13:02:06.633
cmrknuu5v03nt4hlesolh4ilr	cmrknukf5006z4hleqkmh6fuc	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	1800000	f	\N	2026-07-14 13:02:06.644	2026-07-14 13:02:06.644
cmrknuu6703nx4hlev6qqnrc0	cmrknukf5006z4hleqkmh6fuc	cmrkbbzjk000amneoowf62wmn	COPY	\N	1200000	f	\N	2026-07-14 13:02:06.656	2026-07-14 13:02:06.656
cmrknuu6j03o14hlesbt6g15b	cmrknuonx01qp4hlezieomuv6	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	2700000	f	\N	2026-07-14 13:02:06.667	2026-07-14 13:02:06.667
cmrknuu6t03o54hleo0e388xe	cmrknuonx01qp4hlezieomuv6	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	1900000	f	\N	2026-07-14 13:02:06.677	2026-07-14 13:02:06.677
cmrknuu7303o94hley8u2mj7f	cmrknuonx01qp4hlezieomuv6	cmrkbbzjk000amneoowf62wmn	COPY	\N	1400000	f	\N	2026-07-14 13:02:06.688	2026-07-14 13:02:06.688
cmrknuu7d03od4hlesoct8cjj	cmrknuki300934hle8ixf92ig	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	2300000	f	\N	2026-07-14 13:02:06.698	2026-07-14 13:02:06.698
cmrknuu7o03oh4hledf0gxvrl	cmrknuki300934hle8ixf92ig	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	1700000	f	\N	2026-07-14 13:02:06.708	2026-07-14 13:02:06.708
cmrknuu7z03ol4hlewrgcp3g3	cmrknuki300934hle8ixf92ig	cmrkbbzjk000amneoowf62wmn	COPY	\N	1200000	f	\N	2026-07-14 13:02:06.719	2026-07-14 13:02:06.719
cmrknuu8903op4hled7ihz0u8	cmrknuo7k01g54hleyba4r0x1	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	2750000	f	\N	2026-07-14 13:02:06.729	2026-07-14 13:02:06.729
cmrknuu8k03ot4hle6bp97r9o	cmrknuo7k01g54hleyba4r0x1	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	1900000	f	\N	2026-07-14 13:02:06.74	2026-07-14 13:02:06.74
cmrknuu8u03ox4hle0q389who	cmrknuool01r74hle77xz53b6	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	3200000	f	\N	2026-07-14 13:02:06.75	2026-07-14 13:02:06.75
cmrknuu9503p14hletapeszhl	cmrknuool01r74hle77xz53b6	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	2100000	f	\N	2026-07-14 13:02:06.761	2026-07-14 13:02:06.761
cmrknuu9g03p54hlevlj5a8gz	cmrknuool01r74hle77xz53b6	cmrkbbzjk000amneoowf62wmn	COPY	\N	1300000	f	\N	2026-07-14 13:02:06.773	2026-07-14 13:02:06.773
cmrknuu9r03p94hlelw4xlvcf	cmrknukcj00634hlez8h4mhht	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	1800000	f	\N	2026-07-14 13:02:06.783	2026-07-14 13:02:06.783
cmrknuua103pd4hlehuu44fpq	cmrknukcj00634hlez8h4mhht	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	1200000	f	\N	2026-07-14 13:02:06.793	2026-07-14 13:02:06.793
cmrknuuac03ph4hle3uqx7i43	cmrknukcj00634hlez8h4mhht	cmrkbbzjk000amneoowf62wmn	COPY	\N	700000	f	\N	2026-07-14 13:02:06.804	2026-07-14 13:02:06.804
cmrknuuan03pl4hlesm5hu642	cmrknuki300934hle8ixf92ig	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	15950000	f	\N	2026-07-14 13:02:06.816	2026-07-14 13:02:06.816
cmrknuuay03pp4hletl9qf7ab	cmrknuki300934hle8ixf92ig	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	13380000	f	\N	2026-07-14 13:02:06.826	2026-07-14 13:02:06.826
cmrknuub903pt4hlezys7vsv7	cmrknuki300934hle8ixf92ig	cmrknut0y039h4hlekczcvqvm	COPY	\N	3950000	f	\N	2026-07-14 13:02:06.837	2026-07-14 13:02:06.837
cmrknuubj03px4hle7qk42a5c	cmrknupdv026f4hlexbzeua3g	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	19480000	f	\N	2026-07-14 13:02:06.847	2026-07-14 13:02:06.847
cmrknuubu03q14hledoebv4qh	cmrknupdv026f4hlexbzeua3g	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	15500000	f	\N	2026-07-14 13:02:06.858	2026-07-14 13:02:06.858
cmrknuuc503q54hleh45z32rp	cmrknupdv026f4hlexbzeua3g	cmrknut0y039h4hlekczcvqvm	COPY	\N	2700000	f	\N	2026-07-14 13:02:06.87	2026-07-14 13:02:06.87
cmrknuucg03q94hle0zl60zl0	cmrknum3k00u34hlelwoa12ez	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	12240000	f	\N	2026-07-14 13:02:06.88	2026-07-14 13:02:06.88
cmrknuucr03qd4hleeauf292z	cmrknum3k00u34hlelwoa12ez	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	9540000	f	\N	2026-07-14 13:02:06.891	2026-07-14 13:02:06.891
cmrknuud203qh4hlefwnd1n13	cmrknum3k00u34hlelwoa12ez	cmrknut0y039h4hlekczcvqvm	COPY	\N	3900000	f	\N	2026-07-14 13:02:06.902	2026-07-14 13:02:06.902
cmrknuudd03ql4hle4btm2r58	cmrknunwf01c54hlel5xsbnv5	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	9820000	f	\N	2026-07-14 13:02:06.913	2026-07-14 13:02:06.913
cmrknuudp03qp4hlekp3fnh6p	cmrknunwf01c54hlel5xsbnv5	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	6400000	f	\N	2026-07-14 13:02:06.925	2026-07-14 13:02:06.925
cmrknuue103qt4hleoc1lpfso	cmrknunwf01c54hlel5xsbnv5	cmrknut0y039h4hlekczcvqvm	COPY	\N	3300000	f	\N	2026-07-14 13:02:06.937	2026-07-14 13:02:06.937
cmrknuuec03qx4hle6uf9ara7	cmrknurk502tv4hledarwecyu	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	25900000	f	\N	2026-07-14 13:02:06.948	2026-07-14 13:02:06.948
cmrknuuen03r14hlet94hmx0b	cmrknurk502tv4hledarwecyu	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	23400000	f	\N	2026-07-14 13:02:06.959	2026-07-14 13:02:06.959
cmrknuuex03r54hlefeqvxv5n	cmrknurk502tv4hledarwecyu	cmrknut0y039h4hlekczcvqvm	COPY	\N	16100000	f	\N	2026-07-14 13:02:06.97	2026-07-14 13:02:06.97
cmrknuuf803r94hleiqtw6dra	cmrknus9i031d4hleoktyupw4	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	4550000	f	\N	2026-07-14 13:02:06.98	2026-07-14 13:02:06.98
cmrknuufj03rd4hles5l1h48j	cmrknus9i031d4hleoktyupw4	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	3250000	f	\N	2026-07-14 13:02:06.991	2026-07-14 13:02:06.991
cmrknuufu03rh4hle9opnrzks	cmrknus9i031d4hleoktyupw4	cmrknut0y039h4hlekczcvqvm	COPY	\N	1800000	f	\N	2026-07-14 13:02:07.002	2026-07-14 13:02:07.002
cmrknuug403rl4hlefpv7yo2s	cmrknunwm01c74hlesrwvz511	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	12950000	f	\N	2026-07-14 13:02:07.013	2026-07-14 13:02:07.013
cmrknuuge03rp4hlef9ywk65h	cmrknunwm01c74hlesrwvz511	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	10800000	f	\N	2026-07-14 13:02:07.023	2026-07-14 13:02:07.023
cmrknuugp03rt4hle1zw01xss	cmrknunwm01c74hlesrwvz511	cmrknut0y039h4hlekczcvqvm	COPY	\N	3500000	f	\N	2026-07-14 13:02:07.033	2026-07-14 13:02:07.033
cmrknuugz03rx4hle3zhqbjx9	cmrknumlc00yj4hlecifwdi7b	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	1400000	f	\N	2026-07-14 13:02:07.044	2026-07-14 13:02:07.044
cmrknuuha03s14hlexy0ok5lh	cmrknumlc00yj4hlecifwdi7b	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	900000	f	\N	2026-07-14 13:02:07.054	2026-07-14 13:02:07.054
cmrknuuhk03s54hlel94aagdn	cmrknumlc00yj4hlecifwdi7b	cmrkbbzjk000amneoowf62wmn	COPY	\N	500000	f	\N	2026-07-14 13:02:07.065	2026-07-14 13:02:07.065
cmrknuuhu03s94hleaface58y	cmrknuro602v34hleg39gtijg	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	2900000	f	\N	2026-07-14 13:02:07.075	2026-07-14 13:02:07.075
cmrknuui503sd4hle79rqmxdr	cmrknuro602v34hleg39gtijg	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	1900000	f	\N	2026-07-14 13:02:07.085	2026-07-14 13:02:07.085
cmrknuuif03sh4hlemeydxi0q	cmrknuro602v34hleg39gtijg	cmrkbbzjk000amneoowf62wmn	COPY	\N	1200000	f	\N	2026-07-14 13:02:07.095	2026-07-14 13:02:07.095
cmrknuuiq03sl4hle12tdyh5p	cmrknus80030v4hleepdobkl8	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	2400000	f	\N	2026-07-14 13:02:07.106	2026-07-14 13:02:07.106
cmrknuuj203sp4hlefat6vdoe	cmrknus80030v4hleepdobkl8	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	1700000	f	\N	2026-07-14 13:02:07.119	2026-07-14 13:02:07.119
cmrknuujc03st4hlea3gd3idz	cmrknus80030v4hleepdobkl8	cmrkbbzjk000amneoowf62wmn	COPY	\N	1100000	f	\N	2026-07-14 13:02:07.129	2026-07-14 13:02:07.129
cmrknuujn03sx4hle33gyi6yp	cmrknunwf01c54hlel5xsbnv5	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	4700000	f	\N	2026-07-14 13:02:07.139	2026-07-14 13:02:07.139
cmrknuujx03t14hlezv7nxotq	cmrknunwf01c54hlel5xsbnv5	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	3800000	f	\N	2026-07-14 13:02:07.149	2026-07-14 13:02:07.149
cmrknuuk903t54hlencceze7v	cmrknunwf01c54hlel5xsbnv5	cmrkbbzjk000amneoowf62wmn	COPY	\N	3100000	f	\N	2026-07-14 13:02:07.161	2026-07-14 13:02:07.161
cmrknuukl03t94hleynt65m22	cmrknusga033f4hlelpb105q2	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	2800000	f	\N	2026-07-14 13:02:07.173	2026-07-14 13:02:07.173
cmrknuukw03td4hlex0pdeyi4	cmrknusga033f4hlelpb105q2	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	1800000	f	\N	2026-07-14 13:02:07.184	2026-07-14 13:02:07.184
cmrknuul603th4hleqq056ms3	cmrknusga033f4hlelpb105q2	cmrkbbzjk000amneoowf62wmn	COPY	\N	1200000	f	\N	2026-07-14 13:02:07.194	2026-07-14 13:02:07.194
cmrknuulg03tl4hler5mw8a5r	cmrknul6c00h14hleeh8ukjgn	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	3050000	f	\N	2026-07-14 13:02:07.204	2026-07-14 13:02:07.204
cmrknuulr03tp4hlezg61eejl	cmrknul6c00h14hleeh8ukjgn	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	1900000	f	\N	2026-07-14 13:02:07.215	2026-07-14 13:02:07.215
cmrknuum103tt4hleqegyu8sr	cmrknul6c00h14hleeh8ukjgn	cmrkbbzjk000amneoowf62wmn	COPY	\N	1200000	f	\N	2026-07-14 13:02:07.225	2026-07-14 13:02:07.225
cmrknuumc03tx4hle4fc2afbb	cmrknurk502tv4hledarwecyu	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	4300000	f	\N	2026-07-14 13:02:07.236	2026-07-14 13:02:07.236
cmrknuumm03u14hleod6hpych	cmrknurk502tv4hledarwecyu	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	3200000	f	\N	2026-07-14 13:02:07.246	2026-07-14 13:02:07.246
cmrknuumy03u54hles7y3c09a	cmrknurk502tv4hledarwecyu	cmrkbbzjk000amneoowf62wmn	COPY	\N	2300000	f	\N	2026-07-14 13:02:07.258	2026-07-14 13:02:07.258
cmrknuuna03u94hlewxh40c87	cmrknusa7031l4hlese5bukdo	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	1900000	f	\N	2026-07-14 13:02:07.27	2026-07-14 13:02:07.27
cmrknuunm03ud4hleauexds8q	cmrknusa7031l4hlese5bukdo	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	1400000	f	\N	2026-07-14 13:02:07.282	2026-07-14 13:02:07.282
cmrknuuny03uh4hleinxu280m	cmrknusa7031l4hlese5bukdo	cmrkbbzjk000amneoowf62wmn	COPY	\N	900000	f	\N	2026-07-14 13:02:07.294	2026-07-14 13:02:07.294
cmrknuuo903ul4hle5ix6icip	cmrknung7017n4hleej9wufua	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	2700000	f	\N	2026-07-14 13:02:07.305	2026-07-14 13:02:07.305
cmrknuuol03up4hle4oavu81n	cmrknung7017n4hleej9wufua	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	1900000	f	\N	2026-07-14 13:02:07.317	2026-07-14 13:02:07.317
cmrknuuow03ut4hle0ihdwib5	cmrknung7017n4hleej9wufua	cmrkbbzjk000amneoowf62wmn	COPY	\N	1200000	f	\N	2026-07-14 13:02:07.328	2026-07-14 13:02:07.328
cmrknuup703ux4hlexk8smbgl	cmrknul1x00f34hle0z06dmm6	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	1900000	f	\N	2026-07-14 13:02:07.339	2026-07-14 13:02:07.339
cmrknuupi03v14hlevgy5dzph	cmrknushc033p4hleezt3rmt8	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	1900000	f	\N	2026-07-14 13:02:07.35	2026-07-14 13:02:07.35
cmrknuupt03v54hle0ykhicr5	cmrknushc033p4hleezt3rmt8	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	1500000	f	\N	2026-07-14 13:02:07.361	2026-07-14 13:02:07.361
cmrknuuq403v94hlezm1b1jhn	cmrknushc033p4hleezt3rmt8	cmrkbbzjk000amneoowf62wmn	COPY	\N	1100000	f	\N	2026-07-14 13:02:07.372	2026-07-14 13:02:07.372
cmrknuuqf03vd4hle8sfhm26t	cmrknun1j013r4hlelevvslwu	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	4300000	f	\N	2026-07-14 13:02:07.383	2026-07-14 13:02:07.383
cmrknuuqq03vh4hle88vjvb8q	cmrknun1j013r4hlelevvslwu	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	3100000	f	\N	2026-07-14 13:02:07.394	2026-07-14 13:02:07.394
cmrknuur103vl4hlez8ayb50n	cmrknun1j013r4hlelevvslwu	cmrkbbzjk000amneoowf62wmn	COPY	\N	1400000	f	\N	2026-07-14 13:02:07.405	2026-07-14 13:02:07.405
cmrknuurc03vp4hlelnv2kddb	cmrknusez03314hle881gf5vr	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	2300000	f	\N	2026-07-14 13:02:07.416	2026-07-14 13:02:07.416
cmrknuurn03vt4hleg3l1pgzz	cmrknusez03314hle881gf5vr	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	1700000	f	\N	2026-07-14 13:02:07.427	2026-07-14 13:02:07.427
cmrknuury03vx4hlemjq8ol5h	cmrknusez03314hle881gf5vr	cmrkbbzjk000amneoowf62wmn	COPY	\N	1200000	f	\N	2026-07-14 13:02:07.439	2026-07-14 13:02:07.439
cmrknuus903w14hleynd019av	cmrknus9i031d4hleoktyupw4	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	2300000	f	\N	2026-07-14 13:02:07.45	2026-07-14 13:02:07.45
cmrknuusl03w54hlexs6o9hvs	cmrknus9i031d4hleoktyupw4	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	1700000	f	\N	2026-07-14 13:02:07.461	2026-07-14 13:02:07.461
cmrknuusw03w94hlejsas9rjz	cmrknus9i031d4hleoktyupw4	cmrkbbzjk000amneoowf62wmn	COPY	\N	1200000	f	\N	2026-07-14 13:02:07.472	2026-07-14 13:02:07.472
cmrknuut703wd4hleb6m3ywra	cmrknusc203254hlew2spvu26	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	2450000	f	\N	2026-07-14 13:02:07.483	2026-07-14 13:02:07.483
cmrknuuti03wh4hlejn1vzm8h	cmrknusc203254hlew2spvu26	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	1800000	f	\N	2026-07-14 13:02:07.494	2026-07-14 13:02:07.494
cmrknuutt03wl4hlecctbxnc9	cmrknusc203254hlew2spvu26	cmrkbbzjk000amneoowf62wmn	COPY	\N	1200000	f	\N	2026-07-14 13:02:07.505	2026-07-14 13:02:07.505
cmrknuuu403wp4hlekdhirobq	cmrknus8i03114hletjrabgwq	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	2400000	f	\N	2026-07-14 13:02:07.516	2026-07-14 13:02:07.516
cmrknuuuf03wt4hleocroe9rr	cmrknus8i03114hletjrabgwq	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	1800000	f	\N	2026-07-14 13:02:07.527	2026-07-14 13:02:07.527
cmrknuuuq03wx4hlez6024xrx	cmrknus8i03114hletjrabgwq	cmrkbbzjk000amneoowf62wmn	COPY	\N	1200000	f	\N	2026-07-14 13:02:07.538	2026-07-14 13:02:07.538
cmrknuuv103x14hlecl2p11yd	cmrknuriw02t34hlegycrtg44	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	2450000	f	\N	2026-07-14 13:02:07.549	2026-07-14 13:02:07.549
cmrknuuvc03x54hle63itxww6	cmrknuriw02t34hlegycrtg44	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	1800000	f	\N	2026-07-14 13:02:07.56	2026-07-14 13:02:07.56
cmrknuuvo03x94hle4udsjr7b	cmrknuriw02t34hlegycrtg44	cmrkbbzjk000amneoowf62wmn	COPY	\N	1200000	f	\N	2026-07-14 13:02:07.572	2026-07-14 13:02:07.572
cmrknuuvz03xd4hleh9hdjku1	cmrknuqre02kf4hlefzxppos4	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	3800000	f	\N	2026-07-14 13:02:07.583	2026-07-14 13:02:07.583
cmrknuuwa03xh4hle2zt3wjav	cmrknuqre02kf4hlefzxppos4	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	2900000	f	\N	2026-07-14 13:02:07.594	2026-07-14 13:02:07.594
cmrknuuwl03xl4hlemvx3reje	cmrknuqre02kf4hlefzxppos4	cmrkbbzjk000amneoowf62wmn	COPY	\N	2200000	f	\N	2026-07-14 13:02:07.605	2026-07-14 13:02:07.605
cmrknuuwx03xp4hlecmnw1xkp	cmrknuqa802fb4hlecn2zu5rr	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	2800000	f	\N	2026-07-14 13:02:07.617	2026-07-14 13:02:07.617
cmrknuux803xt4hlesz8p74id	cmrknuqa802fb4hlecn2zu5rr	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	1900000	f	\N	2026-07-14 13:02:07.628	2026-07-14 13:02:07.628
cmrknuuxi03xx4hlevznikm1a	cmrknuqa802fb4hlecn2zu5rr	cmrkbbzjk000amneoowf62wmn	COPY	\N	1300000	f	\N	2026-07-14 13:02:07.639	2026-07-14 13:02:07.639
cmrknuuxt03y14hle9x25wyj9	cmrknunwm01c74hlesrwvz511	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	3850000	f	\N	2026-07-14 13:02:07.65	2026-07-14 13:02:07.65
cmrknuuy503y54hleghbbwzrl	cmrknunwm01c74hlesrwvz511	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	2900000	f	\N	2026-07-14 13:02:07.661	2026-07-14 13:02:07.661
cmrknuuyf03y94hle215wk8q3	cmrknunwm01c74hlesrwvz511	cmrkbbzjk000amneoowf62wmn	COPY	\N	2300000	f	\N	2026-07-14 13:02:07.672	2026-07-14 13:02:07.672
cmrknuuyp03yd4hle8wvrod0k	cmrknus3x02zn4hle9485qdhb	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	2500000	f	\N	2026-07-14 13:02:07.681	2026-07-14 13:02:07.681
cmrknuuz003yh4hlev7lihlkd	cmrknus3x02zn4hle9485qdhb	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	1850000	f	\N	2026-07-14 13:02:07.692	2026-07-14 13:02:07.692
cmrknuuza03yl4hletluppmc5	cmrknus3x02zn4hle9485qdhb	cmrkbbzjk000amneoowf62wmn	COPY	\N	1200000	f	\N	2026-07-14 13:02:07.703	2026-07-14 13:02:07.703
cmrknuuzl03yp4hleld5ya8j2	cmrknurqk02vr4hler7beqkzr	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	2500000	f	\N	2026-07-14 13:02:07.713	2026-07-14 13:02:07.713
cmrknuuzv03yt4hlet6na3pnn	cmrknurqk02vr4hler7beqkzr	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	1900000	f	\N	2026-07-14 13:02:07.723	2026-07-14 13:02:07.723
cmrknuv0603yx4hlex9q0ov9b	cmrknurqk02vr4hler7beqkzr	cmrkbbzjk000amneoowf62wmn	COPY	\N	1200000	f	\N	2026-07-14 13:02:07.734	2026-07-14 13:02:07.734
cmrknuv0g03z14hle02kltdq1	cmrknus1o02yz4hled2vvh1gd	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	2500000	f	\N	2026-07-14 13:02:07.745	2026-07-14 13:02:07.745
cmrknuv0r03z54hlee6fm525k	cmrknus1o02yz4hled2vvh1gd	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	1900000	f	\N	2026-07-14 13:02:07.755	2026-07-14 13:02:07.755
cmrknuv1203z94hlezd5o7kc5	cmrknus1o02yz4hled2vvh1gd	cmrkbbzjk000amneoowf62wmn	COPY	\N	1200000	f	\N	2026-07-14 13:02:07.766	2026-07-14 13:02:07.766
cmrknuv1c03zd4hle4wa4z2q6	cmrknus1v02z14hleh3ioyxxq	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	2500000	f	\N	2026-07-14 13:02:07.776	2026-07-14 13:02:07.776
cmrknuv1m03zh4hleeuvza1na	cmrknus1v02z14hleh3ioyxxq	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	1900000	f	\N	2026-07-14 13:02:07.786	2026-07-14 13:02:07.786
cmrknuv1x03zl4hleig0fdamr	cmrknus1v02z14hleh3ioyxxq	cmrkbbzjk000amneoowf62wmn	COPY	\N	1200000	f	\N	2026-07-14 13:02:07.797	2026-07-14 13:02:07.797
cmrknuv2803zp4hle2w42npxy	cmrknuk4w002l4hlepsz89rxi	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	2500000	f	\N	2026-07-14 13:02:07.808	2026-07-14 13:02:07.808
cmrknuv2k03zt4hlepampruma	cmrknuk4w002l4hlepsz89rxi	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	1900000	f	\N	2026-07-14 13:02:07.82	2026-07-14 13:02:07.82
cmrknuv2v03zx4hleh27w9943	cmrknuk4w002l4hlepsz89rxi	cmrkbbzjk000amneoowf62wmn	COPY	\N	1200000	f	\N	2026-07-14 13:02:07.831	2026-07-14 13:02:07.831
cmrknuv3504014hlectfbfkjq	cmrknupj9027t4hle7p7wpqj7	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	3900000	f	\N	2026-07-14 13:02:07.842	2026-07-14 13:02:07.842
cmrknuv3h04054hleq7yzjgdn	cmrknupj9027t4hle7p7wpqj7	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	2600000	f	\N	2026-07-14 13:02:07.853	2026-07-14 13:02:07.853
cmrknuv3s04094hletrrdfrkt	cmrknupj9027t4hle7p7wpqj7	cmrkbbzjk000amneoowf62wmn	COPY	\N	1700000	f	\N	2026-07-14 13:02:07.864	2026-07-14 13:02:07.864
cmrknuv43040d4hlei9lbt94f	cmrknurun02wx4hlefzl620dj	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	2800000	f	\N	2026-07-14 13:02:07.875	2026-07-14 13:02:07.875
cmrknuv4e040h4hlejp20q1m4	cmrknurun02wx4hlefzl620dj	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	1900000	f	\N	2026-07-14 13:02:07.887	2026-07-14 13:02:07.887
cmrknuv4q040l4hle895jb34p	cmrknurun02wx4hlefzl620dj	cmrkbbzjk000amneoowf62wmn	COPY	\N	1200000	f	\N	2026-07-14 13:02:07.898	2026-07-14 13:02:07.898
cmrknuv51040p4hlewgu81jf0	cmrknuq5z02e34hlejp111l5i	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	3900000	f	\N	2026-07-14 13:02:07.909	2026-07-14 13:02:07.909
cmrknuv5e040t4hleplzeaj3h	cmrknuq5z02e34hlejp111l5i	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	3100000	f	\N	2026-07-14 13:02:07.922	2026-07-14 13:02:07.922
cmrknuv5q040x4hlerjjubl1o	cmrknuq5z02e34hlejp111l5i	cmrkbbzjk000amneoowf62wmn	COPY	\N	2100000	f	\N	2026-07-14 13:02:07.934	2026-07-14 13:02:07.934
cmrknuv6104114hlev6g28azb	cmrknup0o020t4hle1ydhrjrc	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	3800000	f	\N	2026-07-14 13:02:07.945	2026-07-14 13:02:07.945
cmrknuv6d04154hledxvsuakk	cmrknup0o020t4hle1ydhrjrc	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	2900000	f	\N	2026-07-14 13:02:07.957	2026-07-14 13:02:07.957
cmrknuv6p04194hlep6s202lv	cmrknup0o020t4hle1ydhrjrc	cmrkbbzjk000amneoowf62wmn	COPY	\N	2200000	f	\N	2026-07-14 13:02:07.969	2026-07-14 13:02:07.969
cmrknuv6z041d4hleyatweol2	cmrknunlx019h4hle78wrfxn3	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	3900000	f	\N	2026-07-14 13:02:07.979	2026-07-14 13:02:07.979
cmrknuv7a041h4hledmvmnit0	cmrknunlx019h4hle78wrfxn3	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	3050000	f	\N	2026-07-14 13:02:07.99	2026-07-14 13:02:07.99
cmrknuv7n041l4hle9c9zi4rj	cmrknunlx019h4hle78wrfxn3	cmrkbbzjk000amneoowf62wmn	COPY	\N	2300000	f	\N	2026-07-14 13:02:08.003	2026-07-14 13:02:08.003
cmrknuv7y041p4hle10z7j4og	cmrknukhg008j4hle3cbbnfvr	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	4500000	f	\N	2026-07-14 13:02:08.015	2026-07-14 13:02:08.015
cmrknuv89041t4hleimuoy59c	cmrknukhg008j4hle3cbbnfvr	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	3700000	f	\N	2026-07-14 13:02:08.025	2026-07-14 13:02:08.025
cmrknuv8k041x4hle1fkbigex	cmrknukhg008j4hle3cbbnfvr	cmrkbbzjk000amneoowf62wmn	COPY	\N	3000000	f	\N	2026-07-14 13:02:08.036	2026-07-14 13:02:08.036
cmrknuv8t04214hlehr1axg3r	cmrknuslh034x4hle52ouxrh3	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	4900000	f	\N	2026-07-14 13:02:08.046	2026-07-14 13:02:08.046
cmrknuv9404254hlefzmb1sy6	cmrknuslh034x4hle52ouxrh3	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	4050000	f	\N	2026-07-14 13:02:08.056	2026-07-14 13:02:08.056
cmrknuv9f04294hleenud5pcg	cmrknuslh034x4hle52ouxrh3	cmrkbbzjk000amneoowf62wmn	COPY	\N	3200000	f	\N	2026-07-14 13:02:08.067	2026-07-14 13:02:08.067
cmrknuv9q042d4hle9ps1clpt	cmrknuslb034v4hleeqaes1ky	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	4900000	f	\N	2026-07-14 13:02:08.078	2026-07-14 13:02:08.078
cmrknuva1042h4hler9i2sy38	cmrknuslb034v4hleeqaes1ky	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	4050000	f	\N	2026-07-14 13:02:08.089	2026-07-14 13:02:08.089
cmrknuvab042l4hlepduzd9yk	cmrknuslb034v4hleeqaes1ky	cmrkbbzjk000amneoowf62wmn	COPY	\N	3200000	f	\N	2026-07-14 13:02:08.1	2026-07-14 13:02:08.1
cmrknuvan042p4hle0arhyxde	cmrknuslp034z4hlepmsig8d8	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	7890000	f	\N	2026-07-14 13:02:08.111	2026-07-14 13:02:08.111
cmrknuvay042t4hlegkqrei5h	cmrknuslp034z4hlepmsig8d8	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	5250000	f	\N	2026-07-14 13:02:08.123	2026-07-14 13:02:08.123
cmrknuvb9042x4hlei9gvx9yc	cmrknuslp034z4hlepmsig8d8	cmrknut0y039h4hlekczcvqvm	COPY	\N	2500000	f	\N	2026-07-14 13:02:08.133	2026-07-14 13:02:08.133
cmrknuvbj04314hle1futlccm	cmrknukj1009x4hle6uioxq9r	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	19850000	f	\N	2026-07-14 13:02:08.143	2026-07-14 13:02:08.143
cmrknuvbt04354hlet1ym9scq	cmrknukj1009x4hle6uioxq9r	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	12380000	f	\N	2026-07-14 13:02:08.153	2026-07-14 13:02:08.153
cmrknuvc304394hleyl9aa7it	cmrknukj1009x4hle6uioxq9r	cmrknut0y039h4hlekczcvqvm	COPY	\N	6900000	f	\N	2026-07-14 13:02:08.163	2026-07-14 13:02:08.163
cmrknuvce043d4hlejvwjr477	cmrknusm403534hleg0ak87ub	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	44620000	f	\N	2026-07-14 13:02:08.174	2026-07-14 13:02:08.174
cmrknuvco043h4hlezxr022dp	cmrknusm403534hleg0ak87ub	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	36700000	f	\N	2026-07-14 13:02:08.184	2026-07-14 13:02:08.184
cmrknuvcz043l4hle6mxyz5iy	cmrknusm403534hleg0ak87ub	cmrknut0y039h4hlekczcvqvm	COPY	\N	22120000	f	\N	2026-07-14 13:02:08.195	2026-07-14 13:02:08.195
cmrknuvd9043p4hleeejm82fv	cmrknuqlf02il4hleobcygeb7	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	14960000	f	\N	2026-07-14 13:02:08.205	2026-07-14 13:02:08.205
cmrknuvdk043t4hle38asf24f	cmrknuqlf02il4hleobcygeb7	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	12400000	f	\N	2026-07-14 13:02:08.216	2026-07-14 13:02:08.216
cmrknuvdt043x4hlebj2ibl27	cmrknuqlf02il4hleobcygeb7	cmrknut0y039h4hlekczcvqvm	COPY	\N	3800000	f	\N	2026-07-14 13:02:08.226	2026-07-14 13:02:08.226
cmrknuve404414hle7c92q92b	cmrknuk9x00554hle9um1cc7q	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	57380000	f	\N	2026-07-14 13:02:08.236	2026-07-14 13:02:08.236
cmrknuvee04454hlelgnnn7fc	cmrknuk9x00554hle9um1cc7q	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	52400000	f	\N	2026-07-14 13:02:08.246	2026-07-14 13:02:08.246
cmrknuvep04494hle9auykofe	cmrknuk9x00554hle9um1cc7q	cmrknut0y039h4hlekczcvqvm	COPY	\N	41000000	f	\N	2026-07-14 13:02:08.257	2026-07-14 13:02:08.257
cmrknuvf1044d4hlegtz9j4el	cmrknuki100914hleaxh4lulp	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	49800000	f	\N	2026-07-14 13:02:08.269	2026-07-14 13:02:08.269
cmrknuvfc044h4hlee3rj74zl	cmrknuki100914hleaxh4lulp	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	41500000	f	\N	2026-07-14 13:02:08.28	2026-07-14 13:02:08.28
cmrknuvfm044l4hlec5bn2yec	cmrknuki100914hleaxh4lulp	cmrknut0y039h4hlekczcvqvm	COPY	\N	34600000	f	\N	2026-07-14 13:02:08.291	2026-07-14 13:02:08.291
cmrknuvfx044p4hletyc94f6w	cmrknurr502vx4hle7a5jpm1p	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	2950000	f	\N	2026-07-14 13:02:08.302	2026-07-14 13:02:08.302
cmrknuvg8044t4hlebqh7ittv	cmrknurr502vx4hle7a5jpm1p	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	1690000	f	\N	2026-07-14 13:02:08.313	2026-07-14 13:02:08.313
cmrknuvgj044x4hlehlup1mc6	cmrknurr502vx4hle7a5jpm1p	cmrknut0y039h4hlekczcvqvm	COPY	\N	1100000	f	\N	2026-07-14 13:02:08.324	2026-07-14 13:02:08.324
cmrknuvgv04514hlekaafluuk	cmrknuk50002n4hlevq2b3czx	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	3680000	f	\N	2026-07-14 13:02:08.335	2026-07-14 13:02:08.335
cmrknuvh704554hled9cvlds5	cmrknuk50002n4hlevq2b3czx	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	2730000	f	\N	2026-07-14 13:02:08.346	2026-07-14 13:02:08.346
cmrknuvhj04594hle667zxxik	cmrknuk50002n4hlevq2b3czx	cmrknut0y039h4hlekczcvqvm	COPY	\N	1700000	f	\N	2026-07-14 13:02:08.359	2026-07-14 13:02:08.359
cmrknuvhu045d4hleqw5b7eqq	cmrknuk7e003x4hleakqib6r2	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	3620000	f	\N	2026-07-14 13:02:08.371	2026-07-14 13:02:08.371
cmrknuvi6045h4hle14nsx2vp	cmrknuk7e003x4hleakqib6r2	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	2890000	f	\N	2026-07-14 13:02:08.382	2026-07-14 13:02:08.382
cmrknuvih045l4hletxo35ot7	cmrknuk7e003x4hleakqib6r2	cmrknut0y039h4hlekczcvqvm	COPY	\N	1700000	f	\N	2026-07-14 13:02:08.394	2026-07-14 13:02:08.394
cmrknuvit045p4hleinxl6taf	cmrknurjw02tr4hlevgx3re8a	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	7880000	f	\N	2026-07-14 13:02:08.405	2026-07-14 13:02:08.405
cmrknuvj5045t4hleqmw1x5f2	cmrknurjw02tr4hlevgx3re8a	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	5780000	f	\N	2026-07-14 13:02:08.417	2026-07-14 13:02:08.417
cmrknuvjg045x4hle7r0oaxm9	cmrknurjw02tr4hlevgx3re8a	cmrknut0y039h4hlekczcvqvm	COPY	\N	1900000	f	\N	2026-07-14 13:02:08.428	2026-07-14 13:02:08.428
cmrknuvjs04614hlexlbj7qw0	cmrknurv702x34hle7iu4ikqt	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	3750000	f	\N	2026-07-14 13:02:08.44	2026-07-14 13:02:08.44
cmrknuvk304654hlej3k4mmmc	cmrknurv702x34hle7iu4ikqt	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	2900000	f	\N	2026-07-14 13:02:08.452	2026-07-14 13:02:08.452
cmrknuvkg04694hlej7xrz8ft	cmrknurv702x34hle7iu4ikqt	cmrknut0y039h4hlekczcvqvm	COPY	\N	1600000	f	\N	2026-07-14 13:02:08.464	2026-07-14 13:02:08.464
cmrknuvkr046d4hledrp1e785	cmrknurjk02tl4hle7am0uqrf	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	13320000	f	\N	2026-07-14 13:02:08.475	2026-07-14 13:02:08.475
cmrknuvl3046h4hlewesnccon	cmrknurjk02tl4hle7am0uqrf	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	8590000	f	\N	2026-07-14 13:02:08.487	2026-07-14 13:02:08.487
cmrknuvle046l4hlec96xzxmk	cmrknurjk02tl4hle7am0uqrf	cmrknut0y039h4hlekczcvqvm	COPY	\N	2200000	f	\N	2026-07-14 13:02:08.498	2026-07-14 13:02:08.498
cmrknuvlq046p4hlehd1nmpon	cmrknukf5006z4hleqkmh6fuc	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	11980000	f	\N	2026-07-14 13:02:08.51	2026-07-14 13:02:08.51
cmrknuvm1046t4hle5fnxhegf	cmrknukf5006z4hleqkmh6fuc	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	9450000	f	\N	2026-07-14 13:02:08.521	2026-07-14 13:02:08.521
cmrknuvmd046x4hle2lvikav8	cmrknukf5006z4hleqkmh6fuc	cmrknut0y039h4hlekczcvqvm	COPY	\N	2300000	f	\N	2026-07-14 13:02:08.533	2026-07-14 13:02:08.533
cmrknuvmo04714hlemzt28m2k	cmrknukge007t4hle7nzd1gba	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	15980000	f	\N	2026-07-14 13:02:08.544	2026-07-14 13:02:08.544
cmrknuvn004754hlejf6ylksr	cmrknukge007t4hle7nzd1gba	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	12400000	f	\N	2026-07-14 13:02:08.556	2026-07-14 13:02:08.556
cmrknuvnb04794hleoeuk6l87	cmrknukge007t4hle7nzd1gba	cmrknut0y039h4hlekczcvqvm	COPY	\N	3300000	f	\N	2026-07-14 13:02:08.567	2026-07-14 13:02:08.567
cmrknuvnm047d4hlefp4kv7tm	cmrknuo7k01g54hleyba4r0x1	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	16900000	f	\N	2026-07-14 13:02:08.578	2026-07-14 13:02:08.578
cmrknuvny047h4hleq16g7eaf	cmrknuo7k01g54hleyba4r0x1	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	13750000	f	\N	2026-07-14 13:02:08.59	2026-07-14 13:02:08.59
cmrknuvo9047l4hleyekpm8ig	cmrknuo7k01g54hleyba4r0x1	cmrknut0y039h4hlekczcvqvm	COPY	\N	6100000	f	\N	2026-07-14 13:02:08.602	2026-07-14 13:02:08.602
cmrknuvol047p4hle8n76j61c	cmrknuool01r74hle77xz53b6	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	15450000	f	\N	2026-07-14 13:02:08.613	2026-07-14 13:02:08.613
cmrknuvow047t4hlep5pp5v3b	cmrknuool01r74hle77xz53b6	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	12300000	f	\N	2026-07-14 13:02:08.624	2026-07-14 13:02:08.624
cmrknuvp7047x4hle7404qdej	cmrknuool01r74hle77xz53b6	cmrknut0y039h4hlekczcvqvm	COPY	\N	3200000	f	\N	2026-07-14 13:02:08.636	2026-07-14 13:02:08.636
cmrknuvpi04814hleo6cwoulo	cmrknuntm01bf4hledensl08i	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	13500000	f	\N	2026-07-14 13:02:08.647	2026-07-14 13:02:08.647
cmrknuvpu04854hlesswmrspz	cmrknuntm01bf4hledensl08i	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	10400000	f	\N	2026-07-14 13:02:08.658	2026-07-14 13:02:08.658
cmrknuvq504894hle1e0q6i0q	cmrknuntm01bf4hledensl08i	cmrknut0y039h4hlekczcvqvm	COPY	\N	3200000	f	\N	2026-07-14 13:02:08.669	2026-07-14 13:02:08.669
cmrknuvqf048d4hlefs9jzep0	cmrknurim02sv4hlebagnkftr	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	3150000	f	\N	2026-07-14 13:02:08.679	2026-07-14 13:02:08.679
cmrknuvqp048h4hlez99j1ma6	cmrknurim02sv4hlebagnkftr	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	2480000	f	\N	2026-07-14 13:02:08.69	2026-07-14 13:02:08.69
cmrknuvr0048l4hlec59mo9hn	cmrknurim02sv4hlebagnkftr	cmrknut0y039h4hlekczcvqvm	COPY	\N	1500000	f	\N	2026-07-14 13:02:08.7	2026-07-14 13:02:08.7
cmrknuvrb048p4hle348bwd75	cmrknuncs016r4hlesbt036xz	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	3470000	f	\N	2026-07-14 13:02:08.711	2026-07-14 13:02:08.711
cmrknuvrm048t4hlexnxunhpp	cmrknuncs016r4hlesbt036xz	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	2650000	f	\N	2026-07-14 13:02:08.722	2026-07-14 13:02:08.722
cmrknuvrw048x4hleuaws5yt7	cmrknuncs016r4hlesbt036xz	cmrknut0y039h4hlekczcvqvm	COPY	\N	1700000	f	\N	2026-07-14 13:02:08.732	2026-07-14 13:02:08.732
cmrknuvs604914hle1p9riils	cmrknumbm00w54hlee8bpngkh	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	39000000	f	\N	2026-07-14 13:02:08.742	2026-07-14 13:02:08.742
cmrknuvsg04954hleen5m6lm3	cmrknumbm00w54hlee8bpngkh	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	35600000	f	\N	2026-07-14 13:02:08.752	2026-07-14 13:02:08.752
cmrknuvsr04994hlewj66ay3c	cmrknumbm00w54hlee8bpngkh	cmrknut0y039h4hlekczcvqvm	COPY	\N	31200000	f	\N	2026-07-14 13:02:08.763	2026-07-14 13:02:08.763
cmrknuvt1049d4hlelsb66z24	cmrknusmh03574hleaoy1wipc	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	3470000	f	\N	2026-07-14 13:02:08.773	2026-07-14 13:02:08.773
cmrknuvtb049h4hlef7ap4dnh	cmrknusmh03574hleaoy1wipc	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	2320000	f	\N	2026-07-14 13:02:08.783	2026-07-14 13:02:08.783
cmrknuvtm049l4hlet2wki5yt	cmrknusmh03574hleaoy1wipc	cmrknut0y039h4hlekczcvqvm	COPY	\N	1300000	f	\N	2026-07-14 13:02:08.794	2026-07-14 13:02:08.794
cmrknuvtx049p4hleem03nkj0	cmrknusmw035b4hletixi9cgt	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	5670000	f	\N	2026-07-14 13:02:08.806	2026-07-14 13:02:08.806
cmrknuvua049t4hlezgu6zyvk	cmrknusmw035b4hletixi9cgt	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	4520000	f	\N	2026-07-14 13:02:08.818	2026-07-14 13:02:08.818
cmrknuvum049x4hlewsqqjsll	cmrknusmw035b4hletixi9cgt	cmrknut0y039h4hlekczcvqvm	COPY	\N	1700000	f	\N	2026-07-14 13:02:08.83	2026-07-14 13:02:08.83
cmrknuvuy04a14hleuo76obqs	cmrknusn8035f4hle12ofknao	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	10970000	f	\N	2026-07-14 13:02:08.842	2026-07-14 13:02:08.842
cmrknuvvb04a54hle89rvxzlz	cmrknusn8035f4hle12ofknao	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	8500000	f	\N	2026-07-14 13:02:08.855	2026-07-14 13:02:08.855
cmrknuvvo04a94hleczogtdib	cmrknusn8035f4hle12ofknao	cmrknut0y039h4hlekczcvqvm	COPY	\N	3900000	f	\N	2026-07-14 13:02:08.869	2026-07-14 13:02:08.869
cmrknuvw004ad4hlev78gutnx	cmrknusnf035h4hleqjp3o4de	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	15820000	f	\N	2026-07-14 13:02:08.88	2026-07-14 13:02:08.88
cmrknuvwc04ah4hle0wdn8822	cmrknusnf035h4hleqjp3o4de	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	12800000	f	\N	2026-07-14 13:02:08.892	2026-07-14 13:02:08.892
cmrknuvwq04al4hlejjklfrze	cmrknusnf035h4hleqjp3o4de	cmrknut0y039h4hlekczcvqvm	COPY	\N	6300000	f	\N	2026-07-14 13:02:08.906	2026-07-14 13:02:08.906
cmrknuvx304ap4hle121y4ck4	cmrknurje02th4hleej2cm8uw	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	12800000	f	\N	2026-07-14 13:02:08.919	2026-07-14 13:02:08.919
cmrknuvxf04at4hlelqftnwm7	cmrknurje02th4hleej2cm8uw	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	10200000	f	\N	2026-07-14 13:02:08.932	2026-07-14 13:02:08.932
cmrknuvxs04ax4hleuydys4rr	cmrknurje02th4hleej2cm8uw	cmrknut0y039h4hlekczcvqvm	COPY	\N	3500000	f	\N	2026-07-14 13:02:08.944	2026-07-14 13:02:08.944
cmrknuvy504b14hleo9hxmhnf	cmrknusnn035j4hlemqflbimg	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	3870000	f	\N	2026-07-14 13:02:08.957	2026-07-14 13:02:08.957
cmrknuvyj04b54hle2qzqyart	cmrknusnn035j4hlemqflbimg	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	2720000	f	\N	2026-07-14 13:02:08.971	2026-07-14 13:02:08.971
cmrknuvyx04b94hlee2mh0veh	cmrknusnn035j4hlemqflbimg	cmrknut0y039h4hlekczcvqvm	COPY	\N	1300000	f	\N	2026-07-14 13:02:08.985	2026-07-14 13:02:08.985
cmrknuvz904bd4hle1nww4ezm	cmrknusnt035l4hle78ull8hq	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	5670000	f	\N	2026-07-14 13:02:08.997	2026-07-14 13:02:08.997
cmrknuvzl04bh4hle372uj744	cmrknusnt035l4hle78ull8hq	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	4500000	f	\N	2026-07-14 13:02:09.01	2026-07-14 13:02:09.01
cmrknuvzx04bl4hle2ym3g169	cmrknusnt035l4hle78ull8hq	cmrknut0y039h4hlekczcvqvm	COPY	\N	1800000	f	\N	2026-07-14 13:02:09.021	2026-07-14 13:02:09.021
cmrknuw0704bp4hleeucgdvtq	cmrknuso0035n4hleolzhey0f	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	13950000	f	\N	2026-07-14 13:02:09.031	2026-07-14 13:02:09.031
cmrknuw0h04bt4hlexjhy0m5f	cmrknuso0035n4hleolzhey0f	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	12700000	f	\N	2026-07-14 13:02:09.041	2026-07-14 13:02:09.041
cmrknuw0r04bx4hleyaf97m8p	cmrknuso0035n4hleolzhey0f	cmrknut0y039h4hlekczcvqvm	COPY	\N	3700000	f	\N	2026-07-14 13:02:09.052	2026-07-14 13:02:09.052
cmrknuw1204c14hleo0ot1ap9	cmrknuso6035p4hleg1f5s7qh	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	13820000	f	\N	2026-07-14 13:02:09.062	2026-07-14 13:02:09.062
cmrknuw1d04c54hle2j0clt98	cmrknuso6035p4hleg1f5s7qh	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	10890000	f	\N	2026-07-14 13:02:09.073	2026-07-14 13:02:09.073
cmrknuw1n04c94hlefiwc528e	cmrknuso6035p4hleg1f5s7qh	cmrknut0y039h4hlekczcvqvm	COPY	\N	3300000	f	\N	2026-07-14 13:02:09.084	2026-07-14 13:02:09.084
cmrknuw1y04cd4hleyqgomksq	cmrknusoc035r4hleikj33a89	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	13890000	f	\N	2026-07-14 13:02:09.094	2026-07-14 13:02:09.094
cmrknuw2904ch4hlejh0ovnig	cmrknusoc035r4hleikj33a89	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	9750000	f	\N	2026-07-14 13:02:09.105	2026-07-14 13:02:09.105
cmrknuw2m04cl4hley5bwyziw	cmrknusoc035r4hleikj33a89	cmrknut0y039h4hlekczcvqvm	COPY	\N	5600000	f	\N	2026-07-14 13:02:09.118	2026-07-14 13:02:09.118
cmrknuw2x04cp4hletn6o8lwx	cmrknusoj035t4hleeogpfz30	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	16280000	f	\N	2026-07-14 13:02:09.129	2026-07-14 13:02:09.129
cmrknuw3804ct4hlen4i9g9fi	cmrknusoj035t4hleeogpfz30	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	12800000	f	\N	2026-07-14 13:02:09.14	2026-07-14 13:02:09.14
cmrknuw3j04cx4hlehqdnz37t	cmrknusoj035t4hleeogpfz30	cmrknut0y039h4hlekczcvqvm	COPY	\N	7700000	f	\N	2026-07-14 13:02:09.151	2026-07-14 13:02:09.151
cmrknuw3u04d14hlesbxfk33r	cmrknusop035v4hley486zzxx	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	17300000	f	\N	2026-07-14 13:02:09.162	2026-07-14 13:02:09.162
cmrknuw4604d54hle5kbvrx0i	cmrknusop035v4hley486zzxx	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	13650000	f	\N	2026-07-14 13:02:09.174	2026-07-14 13:02:09.174
cmrknuw4j04d94hlefvwd0ajj	cmrknusop035v4hley486zzxx	cmrknut0y039h4hlekczcvqvm	COPY	\N	7400000	f	\N	2026-07-14 13:02:09.187	2026-07-14 13:02:09.187
cmrknuw4v04dd4hlebvkpqqbu	cmrknusow035x4hle8qsksmw6	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	29650000	f	\N	2026-07-14 13:02:09.199	2026-07-14 13:02:09.199
cmrknuw5704dh4hle2p1o6mkf	cmrknusow035x4hle8qsksmw6	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	25200000	f	\N	2026-07-14 13:02:09.211	2026-07-14 13:02:09.211
cmrknuw5j04dl4hlevv9lia4t	cmrknusow035x4hle8qsksmw6	cmrknut0y039h4hlekczcvqvm	COPY	\N	17400000	f	\N	2026-07-14 13:02:09.224	2026-07-14 13:02:09.224
cmrknuw5w04dp4hleyej5k5nq	cmrknusp2035z4hlez222qrow	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	44770000	f	\N	2026-07-14 13:02:09.236	2026-07-14 13:02:09.236
cmrknuw6604dt4hlefshegyaz	cmrknusp2035z4hlez222qrow	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	38450000	f	\N	2026-07-14 13:02:09.246	2026-07-14 13:02:09.246
cmrknuw6k04dx4hle8pkrekzo	cmrknusp2035z4hlez222qrow	cmrknut0y039h4hlekczcvqvm	COPY	\N	17500000	f	\N	2026-07-14 13:02:09.26	2026-07-14 13:02:09.26
cmrknuw6y04e14hlez4kqfs6k	cmrknusp803614hlevjl6o0vn	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	25820000	f	\N	2026-07-14 13:02:09.274	2026-07-14 13:02:09.274
cmrknuw7b04e54hled9adwx32	cmrknuspf03634hleilvfe3ei	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	42720000	f	\N	2026-07-14 13:02:09.287	2026-07-14 13:02:09.287
cmrknuw7o04e94hledphpu21r	cmrknuspf03634hleilvfe3ei	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	40280000	f	\N	2026-07-14 13:02:09.3	2026-07-14 13:02:09.3
cmrknuw8404ed4hle28c94pn5	cmrknuspf03634hleilvfe3ei	cmrknut0y039h4hlekczcvqvm	COPY	\N	38300000	f	\N	2026-07-14 13:02:09.316	2026-07-14 13:02:09.316
cmrknuw8h04eh4hle493cw0wk	cmrknuspm03654hleoyv47b5y	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	19750000	f	\N	2026-07-14 13:02:09.33	2026-07-14 13:02:09.33
cmrknuw8t04el4hlebqoyx92l	cmrknuspm03654hleoyv47b5y	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	18150000	f	\N	2026-07-14 13:02:09.342	2026-07-14 13:02:09.342
cmrknuw9604ep4hlehsjv5aia	cmrknuspm03654hleoyv47b5y	cmrknut0y039h4hlekczcvqvm	COPY	\N	11100000	f	\N	2026-07-14 13:02:09.354	2026-07-14 13:02:09.354
cmrknuw9m04et4hle82cj1ghm	cmrknusps03674hle1xby3sxk	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	21800000	f	\N	2026-07-14 13:02:09.37	2026-07-14 13:02:09.37
cmrknuw9y04ex4hle4rpaoec0	cmrknusps03674hle1xby3sxk	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	19380000	f	\N	2026-07-14 13:02:09.382	2026-07-14 13:02:09.382
cmrknuwaa04f14hlek06c798r	cmrknusps03674hle1xby3sxk	cmrknut0y039h4hlekczcvqvm	COPY	\N	16300000	f	\N	2026-07-14 13:02:09.394	2026-07-14 13:02:09.394
cmrknuwan04f54hlevzjnvpiu	cmrknusq4036b4hleg1l3l7hs	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	17850000	f	\N	2026-07-14 13:02:09.407	2026-07-14 13:02:09.407
cmrknuwaz04f94hlexkmjk0ov	cmrknusq4036b4hleg1l3l7hs	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	6780000	f	\N	2026-07-14 13:02:09.42	2026-07-14 13:02:09.42
cmrknuwba04fd4hleuxtearyp	cmrknusq4036b4hleg1l3l7hs	cmrknut0y039h4hlekczcvqvm	COPY	\N	2800000	f	\N	2026-07-14 13:02:09.431	2026-07-14 13:02:09.431
cmrknuwbl04fh4hle5qvdggo6	cmrknusqb036d4hlea4u93slk	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	3980000	f	\N	2026-07-14 13:02:09.442	2026-07-14 13:02:09.442
cmrknuwbx04fl4hle0pgtgnt9	cmrknusqb036d4hlea4u93slk	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	2700000	f	\N	2026-07-14 13:02:09.453	2026-07-14 13:02:09.453
cmrknuwc704fp4hleiqns00ko	cmrknusqb036d4hlea4u93slk	cmrknut0y039h4hlekczcvqvm	COPY	\N	1500000	f	\N	2026-07-14 13:02:09.464	2026-07-14 13:02:09.464
cmrknuwci04ft4hlein2ahglc	cmrknusqu036j4hleuajdop36	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	6250000	f	\N	2026-07-14 13:02:09.474	2026-07-14 13:02:09.474
cmrknuwct04fx4hleioe7l8yy	cmrknusqu036j4hleuajdop36	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	4300000	f	\N	2026-07-14 13:02:09.486	2026-07-14 13:02:09.486
cmrknuwd504g14hle1u2v8p81	cmrknusr0036l4hleezwyyicq	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	3750000	f	\N	2026-07-14 13:02:09.497	2026-07-14 13:02:09.497
cmrknuwdg04g54hlezjdgain4	cmrknusr0036l4hleezwyyicq	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	2500000	f	\N	2026-07-14 13:02:09.509	2026-07-14 13:02:09.509
cmrknuwdt04g94hletdyd0m40	cmrknusr0036l4hleezwyyicq	cmrknut0y039h4hlekczcvqvm	COPY	\N	1800000	f	\N	2026-07-14 13:02:09.522	2026-07-14 13:02:09.522
cmrknuwe604gd4hlergvfgena	cmrknusr7036n4hleswn41n1q	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	4220000	f	\N	2026-07-14 13:02:09.534	2026-07-14 13:02:09.534
cmrknuweg04gh4hlefbjspn8b	cmrknusr7036n4hleswn41n1q	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	2950000	f	\N	2026-07-14 13:02:09.544	2026-07-14 13:02:09.544
cmrknuwes04gl4hlevdy7zega	cmrknusr7036n4hleswn41n1q	cmrknut0y039h4hlekczcvqvm	COPY	\N	2000000	f	\N	2026-07-14 13:02:09.556	2026-07-14 13:02:09.556
cmrknuwf304gp4hleytc52pkw	cmrknusrd036p4hlembnt5b04	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	4620000	f	\N	2026-07-14 13:02:09.568	2026-07-14 13:02:09.568
cmrknuwfe04gt4hlegvikwxng	cmrknusrd036p4hlembnt5b04	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	3780000	f	\N	2026-07-14 13:02:09.578	2026-07-14 13:02:09.578
cmrknuwfq04gx4hlec29e4zzo	cmrknusrd036p4hlembnt5b04	cmrknut0y039h4hlekczcvqvm	COPY	\N	2400000	f	\N	2026-07-14 13:02:09.59	2026-07-14 13:02:09.59
cmrknuwg104h14hleqttauf9j	cmrknusrj036r4hledswso0c4	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	37620000	f	\N	2026-07-14 13:02:09.601	2026-07-14 13:02:09.601
cmrknuwgc04h54hle7gl6cwvj	cmrknusrj036r4hledswso0c4	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	33640000	f	\N	2026-07-14 13:02:09.613	2026-07-14 13:02:09.613
cmrknuwgn04h94hle02zgqvkm	cmrknusrj036r4hledswso0c4	cmrknut0y039h4hlekczcvqvm	COPY	\N	14500000	f	\N	2026-07-14 13:02:09.624	2026-07-14 13:02:09.624
cmrknuwgz04hd4hle62cicv6s	cmrknusv9037v4hlehq251mx1	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	15280000	f	\N	2026-07-14 13:02:09.635	2026-07-14 13:02:09.635
cmrknuwha04hh4hlelfrnc8oi	cmrknusv9037v4hlehq251mx1	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	12340000	f	\N	2026-07-14 13:02:09.647	2026-07-14 13:02:09.647
cmrknuwhm04hl4hley723xaz8	cmrknusv9037v4hlehq251mx1	cmrknut0y039h4hlekczcvqvm	COPY	\N	2900000	f	\N	2026-07-14 13:02:09.658	2026-07-14 13:02:09.658
cmrknuwhx04hp4hle10gpb3om	cmrknusrw036v4hle6f1q2krx	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	14950000	f	\N	2026-07-14 13:02:09.669	2026-07-14 13:02:09.669
cmrknuwi804ht4hlesc7dqx75	cmrknusrw036v4hle6f1q2krx	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	12300000	f	\N	2026-07-14 13:02:09.68	2026-07-14 13:02:09.68
cmrknuwij04hx4hlet7imagfb	cmrknusrw036v4hle6f1q2krx	cmrknut0y039h4hlekczcvqvm	COPY	\N	2800000	f	\N	2026-07-14 13:02:09.691	2026-07-14 13:02:09.691
cmrknuwiv04i14hletvgcmp9l	cmrknuss3036x4hlelrl3bhex	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	15380000	f	\N	2026-07-14 13:02:09.703	2026-07-14 13:02:09.703
cmrknuwj704i54hleldxo62gw	cmrknuss3036x4hlelrl3bhex	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	12400000	f	\N	2026-07-14 13:02:09.715	2026-07-14 13:02:09.715
cmrknuwjh04i94hlewx3261ei	cmrknuss3036x4hlelrl3bhex	cmrknut0y039h4hlekczcvqvm	COPY	\N	2800000	f	\N	2026-07-14 13:02:09.725	2026-07-14 13:02:09.725
cmrknuwjs04id4hlejeugx6de	cmrknussa036z4hlef4q2ewac	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	15200000	f	\N	2026-07-14 13:02:09.737	2026-07-14 13:02:09.737
cmrknuwk304ih4hle6fqckt3i	cmrknussa036z4hlef4q2ewac	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	12550000	f	\N	2026-07-14 13:02:09.748	2026-07-14 13:02:09.748
cmrknuwke04il4hleg9at53at	cmrknussa036z4hlef4q2ewac	cmrknut0y039h4hlekczcvqvm	COPY	\N	5200000	f	\N	2026-07-14 13:02:09.758	2026-07-14 13:02:09.758
cmrknuwkp04ip4hle7fbeocci	cmrknussg03714hlezpyagt86	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	15400000	f	\N	2026-07-14 13:02:09.769	2026-07-14 13:02:09.769
cmrknuwky04it4hleporsnq6k	cmrknussg03714hlezpyagt86	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	13600000	f	\N	2026-07-14 13:02:09.779	2026-07-14 13:02:09.779
cmrknuwl904ix4hlen0bsh25r	cmrknussg03714hlezpyagt86	cmrknut0y039h4hlekczcvqvm	COPY	\N	3600000	f	\N	2026-07-14 13:02:09.789	2026-07-14 13:02:09.789
cmrknuwll04j14hleu7lgz2s3	cmrknussn03734hle6r8s27ea	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	15380000	f	\N	2026-07-14 13:02:09.801	2026-07-14 13:02:09.801
cmrknuwlw04j54hlex3tis2a8	cmrknussn03734hle6r8s27ea	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	12400000	f	\N	2026-07-14 13:02:09.812	2026-07-14 13:02:09.812
cmrknuwm604j94hle8wol890w	cmrknussn03734hle6r8s27ea	cmrknut0y039h4hlekczcvqvm	COPY	\N	2800000	f	\N	2026-07-14 13:02:09.823	2026-07-14 13:02:09.823
cmrknuwmi04jd4hlepwmho7t3	cmrknusst03754hle3kxsdkwa	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	15380000	f	\N	2026-07-14 13:02:09.834	2026-07-14 13:02:09.834
cmrknuwmr04jh4hleojsilmfz	cmrknusst03754hle3kxsdkwa	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	12200000	f	\N	2026-07-14 13:02:09.844	2026-07-14 13:02:09.844
cmrknuwn104jl4hledm5uev6j	cmrknusst03754hle3kxsdkwa	cmrknut0y039h4hlekczcvqvm	COPY	\N	2800000	f	\N	2026-07-14 13:02:09.854	2026-07-14 13:02:09.854
cmrknuwnd04jp4hlehfy25w9b	cmrknust603794hlexsqt4q5q	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	15720000	f	\N	2026-07-14 13:02:09.865	2026-07-14 13:02:09.865
cmrknuwnn04jt4hle5hs7axm5	cmrknust603794hlexsqt4q5q	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	12300000	f	\N	2026-07-14 13:02:09.876	2026-07-14 13:02:09.876
cmrknuwnz04jx4hle4lk70luj	cmrknust603794hlexsqt4q5q	cmrknut0y039h4hlekczcvqvm	COPY	\N	2800000	f	\N	2026-07-14 13:02:09.887	2026-07-14 13:02:09.887
cmrknuwoa04k14hlezr4q6i35	cmrknustc037b4hlebf3y3nn3	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	15750000	f	\N	2026-07-14 13:02:09.899	2026-07-14 13:02:09.899
cmrknuwom04k54hle0m4p6sa5	cmrknustc037b4hlebf3y3nn3	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	12700000	f	\N	2026-07-14 13:02:09.91	2026-07-14 13:02:09.91
cmrknuwox04k94hley15pym1d	cmrknustc037b4hlebf3y3nn3	cmrknut0y039h4hlekczcvqvm	COPY	\N	2900000	f	\N	2026-07-14 13:02:09.922	2026-07-14 13:02:09.922
cmrknuwpa04kd4hlec429836n	cmrknusti037d4hlem8kn5scy	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	11380000	f	\N	2026-07-14 13:02:09.934	2026-07-14 13:02:09.934
cmrknuwpl04kh4hlezy46nsn7	cmrknusti037d4hlem8kn5scy	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	8500000	f	\N	2026-07-14 13:02:09.945	2026-07-14 13:02:09.945
cmrknuwpw04kl4hle7w7nr0y9	cmrknustp037f4hlejrdfo4rn	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	11550000	f	\N	2026-07-14 13:02:09.956	2026-07-14 13:02:09.956
cmrknuwq804kp4hle6u93z55e	cmrknustp037f4hlejrdfo4rn	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	8900000	f	\N	2026-07-14 13:02:09.969	2026-07-14 13:02:09.969
cmrknuwqj04kt4hlebxef3lkh	cmrknusun037p4hle3s5b6iqe	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	8680000	f	\N	2026-07-14 13:02:09.979	2026-07-14 13:02:09.979
cmrknuwqu04kx4hlesqimwnod	cmrknusun037p4hle3s5b6iqe	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	6500000	f	\N	2026-07-14 13:02:09.99	2026-07-14 13:02:09.99
cmrknuwr504l14hleilfghq4v	cmrknusun037p4hle3s5b6iqe	cmrknut0y039h4hlekczcvqvm	COPY	\N	4800000	f	\N	2026-07-14 13:02:10.002	2026-07-14 13:02:10.002
cmrknuwrh04l54hlej40wmajd	cmrknusuv037r4hlenwircxkm	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	52000000	f	\N	2026-07-14 13:02:10.013	2026-07-14 13:02:10.013
cmrknuwrr04l94hle0iuoy6dk	cmrknusv2037t4hlefz4zvbe8	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	5750000	f	\N	2026-07-14 13:02:10.023	2026-07-14 13:02:10.023
cmrknuws204ld4hle1sparyvn	cmrknusv2037t4hlefz4zvbe8	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	3900000	f	\N	2026-07-14 13:02:10.034	2026-07-14 13:02:10.034
cmrknuwsc04lh4hlekj9vgzh9	cmrknusv2037t4hlefz4zvbe8	cmrknut0y039h4hlekczcvqvm	COPY	\N	1500000	f	\N	2026-07-14 13:02:10.044	2026-07-14 13:02:10.044
cmrknuwsn04ll4hle0p5k3q5v	cmrknurjr02tp4hle9deqpobv	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	4900000	f	\N	2026-07-14 13:02:10.055	2026-07-14 13:02:10.055
cmrknuwsy04lp4hleskrikn9f	cmrknurjr02tp4hle9deqpobv	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	3860000	f	\N	2026-07-14 13:02:10.066	2026-07-14 13:02:10.066
cmrknuwt804lt4hlenyk2ybnc	cmrknurjr02tp4hle9deqpobv	cmrknut0y039h4hlekczcvqvm	COPY	\N	1750000	f	\N	2026-07-14 13:02:10.076	2026-07-14 13:02:10.076
cmrknuwtj04lx4hle59dk3lx4	cmrknuro602v34hleg39gtijg	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	10500000	f	\N	2026-07-14 13:02:10.087	2026-07-14 13:02:10.087
cmrknuwtt04m14hlecmyrzhot	cmrknuro602v34hleg39gtijg	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	6300000	f	\N	2026-07-14 13:02:10.097	2026-07-14 13:02:10.097
cmrknuwu404m54hlez788hpne	cmrknuro602v34hleg39gtijg	cmrknut0y039h4hlekczcvqvm	COPY	\N	2700000	f	\N	2026-07-14 13:02:10.109	2026-07-14 13:02:10.109
cmrknuwug04m94hlesdmvz9xo	cmrknuq3d02dd4hlesdxwqafp	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	5650000	f	\N	2026-07-14 13:02:10.12	2026-07-14 13:02:10.12
cmrknuwup04md4hle6n21g2dw	cmrknuq3d02dd4hlesdxwqafp	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	4750000	f	\N	2026-07-14 13:02:10.129	2026-07-14 13:02:10.129
cmrknuwuz04mh4hlemrhya7t8	cmrknuq3d02dd4hlesdxwqafp	cmrknut0y039h4hlekczcvqvm	COPY	\N	2700000	f	\N	2026-07-14 13:02:10.14	2026-07-14 13:02:10.14
cmrknuwva04ml4hleuz9et9yn	cmrknul6c00h14hleeh8ukjgn	cmrknut1l039k4hle0hr62dc5	ORIGINAL	\N	11870000	f	\N	2026-07-14 13:02:10.15	2026-07-14 13:02:10.15
cmrknuwvk04mp4hleqa3tgdll	cmrknul6c00h14hleeh8ukjgn	cmrknut1l039k4hle0hr62dc5	HIGH_COPY	\N	7400000	f	\N	2026-07-14 13:02:10.161	2026-07-14 13:02:10.161
cmrknuwvv04mt4hlezu72fpgq	cmrknul6c00h14hleeh8ukjgn	cmrknut1l039k4hle0hr62dc5	COPY	\N	4300000	f	\N	2026-07-14 13:02:10.171	2026-07-14 13:02:10.171
cmrknuww504mx4hlengdgszew	cmrknunm7019l4hle708bakve	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	11400000	f	\N	2026-07-14 13:02:10.181	2026-07-14 13:02:10.181
cmrknuwwf04n14hleydd5akxp	cmrknunm7019l4hle708bakve	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	8500000	f	\N	2026-07-14 13:02:10.191	2026-07-14 13:02:10.191
cmrknuwwq04n54hleny50fudg	cmrknup09020f4hlehk5avgou	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	9850000	f	\N	2026-07-14 13:02:10.202	2026-07-14 13:02:10.202
cmrknuwx004n94hlesdpef74r	cmrknup09020f4hlehk5avgou	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	7200000	f	\N	2026-07-14 13:02:10.212	2026-07-14 13:02:10.212
cmrknuwxb04nd4hlemmc5dvyl	cmrknusvh037x4hleu56m0lj2	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	12350000	f	\N	2026-07-14 13:02:10.223	2026-07-14 13:02:10.223
cmrknuwxm04nh4hle7l56dt8i	cmrknusvh037x4hleu56m0lj2	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	9580000	f	\N	2026-07-14 13:02:10.234	2026-07-14 13:02:10.234
cmrknuwxx04nl4hleku5yzscr	cmrknusvh037x4hleu56m0lj2	cmrknut0y039h4hlekczcvqvm	COPY	\N	6600000	f	\N	2026-07-14 13:02:10.245	2026-07-14 13:02:10.245
cmrknuwy904np4hlex0ij99bl	cmrknusvo037z4hleai24ag2r	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	26500000	f	\N	2026-07-14 13:02:10.257	2026-07-14 13:02:10.257
cmrknuwym04nt4hle9t6wg691	cmrknusvo037z4hleai24ag2r	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	23450000	f	\N	2026-07-14 13:02:10.27	2026-07-14 13:02:10.27
cmrknuwyw04nx4hle1epp491l	cmrknusvo037z4hleai24ag2r	cmrknut0y039h4hlekczcvqvm	COPY	\N	18000000	f	\N	2026-07-14 13:02:10.281	2026-07-14 13:02:10.281
cmrknuwz704o14hlea4vmxofi	cmrknushc033p4hleezt3rmt8	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	7300000	f	\N	2026-07-14 13:02:10.292	2026-07-14 13:02:10.292
cmrknuwzj04o54hlev76p7llh	cmrknushc033p4hleezt3rmt8	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	4850000	f	\N	2026-07-14 13:02:10.303	2026-07-14 13:02:10.303
cmrknuwzu04o94hleu6o7ezl3	cmrknushc033p4hleezt3rmt8	cmrknut0y039h4hlekczcvqvm	COPY	\N	2600000	f	\N	2026-07-14 13:02:10.315	2026-07-14 13:02:10.315
cmrknux0604od4hleezzf1f44	cmrknusa7031l4hlese5bukdo	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	3200000	f	\N	2026-07-14 13:02:10.326	2026-07-14 13:02:10.326
cmrknux0h04oh4hle8rape8ll	cmrknusa7031l4hlese5bukdo	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	2650000	f	\N	2026-07-14 13:02:10.337	2026-07-14 13:02:10.337
cmrknux0s04ol4hlefuzro4nt	cmrknusa7031l4hlese5bukdo	cmrknut0y039h4hlekczcvqvm	COPY	\N	1700000	f	\N	2026-07-14 13:02:10.348	2026-07-14 13:02:10.348
cmrknux1304op4hlet3wez1fy	cmrknus9o031f4hlez60267k2	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	14850000	f	\N	2026-07-14 13:02:10.36	2026-07-14 13:02:10.36
cmrknux1f04ot4hleskgxhklb	cmrknus9o031f4hlez60267k2	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	9600000	f	\N	2026-07-14 13:02:10.371	2026-07-14 13:02:10.371
cmrknux1p04ox4hlenm3ugn6s	cmrknus9o031f4hlez60267k2	cmrknut0y039h4hlekczcvqvm	COPY	\N	6500000	f	\N	2026-07-14 13:02:10.382	2026-07-14 13:02:10.382
cmrknux2104p14hleujiwwdnm	cmrknurgc02rn4hlebcu3t21w	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	9850000	f	\N	2026-07-14 13:02:10.393	2026-07-14 13:02:10.393
cmrknux2d04p54hlef458wgxl	cmrknurgc02rn4hlebcu3t21w	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	6800000	f	\N	2026-07-14 13:02:10.405	2026-07-14 13:02:10.405
cmrknux2o04p94hler0pclblj	cmrknurgc02rn4hlebcu3t21w	cmrknut0y039h4hlekczcvqvm	COPY	\N	2700000	f	\N	2026-07-14 13:02:10.416	2026-07-14 13:02:10.416
cmrknux2z04pd4hlep5gp2wah	cmrknuo2401dx4hle2lfbgsiq	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	12350000	f	\N	2026-07-14 13:02:10.427	2026-07-14 13:02:10.427
cmrknux3a04ph4hle4d9d52hs	cmrknuo2401dx4hle2lfbgsiq	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	10800000	f	\N	2026-07-14 13:02:10.439	2026-07-14 13:02:10.439
cmrknux3m04pl4hlecdhrkrya	cmrknuo2401dx4hle2lfbgsiq	cmrknut0y039h4hlekczcvqvm	COPY	\N	3300000	f	\N	2026-07-14 13:02:10.45	2026-07-14 13:02:10.45
cmrknux3x04pp4hle73ebtaaq	cmrknusdq032n4hlem7sfwxnc	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	3850000	f	\N	2026-07-14 13:02:10.462	2026-07-14 13:02:10.462
cmrknux4904pt4hle7khchrf5	cmrknusdq032n4hlem7sfwxnc	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	2900000	f	\N	2026-07-14 13:02:10.473	2026-07-14 13:02:10.473
cmrknux4k04px4hle1i9v4avd	cmrknusdq032n4hlem7sfwxnc	cmrknut0y039h4hlekczcvqvm	COPY	\N	1750000	f	\N	2026-07-14 13:02:10.485	2026-07-14 13:02:10.485
cmrknux4w04q14hleeokoq908	cmrknuq9u02f74hle329ujxnm	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	3900000	f	\N	2026-07-14 13:02:10.496	2026-07-14 13:02:10.496
cmrknux5804q54hledq9rv06o	cmrknuq9u02f74hle329ujxnm	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	2950000	f	\N	2026-07-14 13:02:10.508	2026-07-14 13:02:10.508
cmrknux5k04q94hleao1fa6p5	cmrknuq9u02f74hle329ujxnm	cmrknut0y039h4hlekczcvqvm	COPY	\N	1900000	f	\N	2026-07-14 13:02:10.52	2026-07-14 13:02:10.52
cmrknux5v04qd4hle5p0fu8m3	cmrknummy00yx4hletupwjz5h	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	3500000	f	\N	2026-07-14 13:02:10.531	2026-07-14 13:02:10.531
cmrknux6504qh4hleuzmpxaox	cmrknummy00yx4hletupwjz5h	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	2600000	f	\N	2026-07-14 13:02:10.541	2026-07-14 13:02:10.541
cmrknux6i04ql4hlewa6x9z8v	cmrknummy00yx4hletupwjz5h	cmrknut0y039h4hlekczcvqvm	COPY	\N	1900000	f	\N	2026-07-14 13:02:10.554	2026-07-14 13:02:10.554
cmrknux6u04qp4hleafb0q03c	cmrknuomz01pz4hlegs8tgxc2	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	3950000	f	\N	2026-07-14 13:02:10.566	2026-07-14 13:02:10.566
cmrknux7604qt4hle3iosr82c	cmrknuomz01pz4hlegs8tgxc2	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	2650000	f	\N	2026-07-14 13:02:10.578	2026-07-14 13:02:10.578
cmrknux7j04qx4hle4zgdzdyx	cmrknuomz01pz4hlegs8tgxc2	cmrknut0y039h4hlekczcvqvm	COPY	\N	1900000	f	\N	2026-07-14 13:02:10.591	2026-07-14 13:02:10.591
cmrknux7w04r14hleq82hzj65	cmrknusvv03814hlemw0m7zj2	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	12200000	f	\N	2026-07-14 13:02:10.604	2026-07-14 13:02:10.604
cmrknux8904r54hlevfcb8xja	cmrknusvv03814hlemw0m7zj2	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	9200000	f	\N	2026-07-14 13:02:10.617	2026-07-14 13:02:10.617
cmrknux8l04r94hle6f2eowk5	cmrknusvv03814hlemw0m7zj2	cmrknut0y039h4hlekczcvqvm	COPY	\N	7800000	f	\N	2026-07-14 13:02:10.629	2026-07-14 13:02:10.629
cmrknux8z04rd4hlegvn9cuz3	cmrknuk88004d4hled5g02jit	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	5380000	f	\N	2026-07-14 13:02:10.643	2026-07-14 13:02:10.643
cmrknux9c04rh4hlegj4mxmim	cmrknuk88004d4hled5g02jit	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	3950000	f	\N	2026-07-14 13:02:10.657	2026-07-14 13:02:10.657
cmrknux9n04rl4hlewyhppuyc	cmrknuk88004d4hled5g02jit	cmrknut0y039h4hlekczcvqvm	COPY	\N	2700000	f	\N	2026-07-14 13:02:10.668	2026-07-14 13:02:10.668
cmrknux9z04rp4hleefp71f61	cmrknusc203254hlew2spvu26	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	3950000	f	\N	2026-07-14 13:02:10.679	2026-07-14 13:02:10.679
cmrknuxaa04rt4hlelm3ouz36	cmrknusc203254hlew2spvu26	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	2720000	f	\N	2026-07-14 13:02:10.69	2026-07-14 13:02:10.69
cmrknuxan04rx4hle2wps8bco	cmrknusc203254hlew2spvu26	cmrknut0y039h4hlekczcvqvm	COPY	\N	1900000	f	\N	2026-07-14 13:02:10.703	2026-07-14 13:02:10.703
cmrknuxay04s14hleul7sp8xf	cmrknus8i03114hletjrabgwq	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	14800000	f	\N	2026-07-14 13:02:10.714	2026-07-14 13:02:10.714
cmrknuxba04s54hle10q8nnrf	cmrknus8i03114hletjrabgwq	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	12450000	f	\N	2026-07-14 13:02:10.726	2026-07-14 13:02:10.726
cmrknuxbm04s94hlee4gatoty	cmrknus8i03114hletjrabgwq	cmrknut0y039h4hlekczcvqvm	COPY	\N	2700000	f	\N	2026-07-14 13:02:10.739	2026-07-14 13:02:10.739
cmrknuxby04sd4hletqx4rscg	cmrknuriw02t34hlegycrtg44	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	14850000	f	\N	2026-07-14 13:02:10.75	2026-07-14 13:02:10.75
cmrknuxc904sh4hlesdcnrfqj	cmrknuriw02t34hlegycrtg44	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	12650000	f	\N	2026-07-14 13:02:10.761	2026-07-14 13:02:10.761
cmrknuxck04sl4hlel2jx6nyk	cmrknuriw02t34hlegycrtg44	cmrknut0y039h4hlekczcvqvm	COPY	\N	2800000	f	\N	2026-07-14 13:02:10.772	2026-07-14 13:02:10.772
cmrknuxcv04sp4hleblz9z1lw	cmrknuspy03694hleoblpugdm	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	17700000	f	\N	2026-07-14 13:02:10.783	2026-07-14 13:02:10.783
cmrknuxd604st4hlej6ktau2l	cmrknuspy03694hleoblpugdm	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	13800000	f	\N	2026-07-14 13:02:10.794	2026-07-14 13:02:10.794
cmrknuxdg04sx4hlekwbdjffm	cmrknuspy03694hleoblpugdm	cmrknut0y039h4hlekczcvqvm	COPY	\N	10200000	f	\N	2026-07-14 13:02:10.805	2026-07-14 13:02:10.805
cmrknuxdr04t14hleufs4zb19	cmrknuog001kb4hle3xbh9az9	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	18800000	f	\N	2026-07-14 13:02:10.816	2026-07-14 13:02:10.816
cmrknuxe404t54hleam7imlbj	cmrknuog001kb4hle3xbh9az9	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	14500000	f	\N	2026-07-14 13:02:10.829	2026-07-14 13:02:10.829
cmrknuxeg04t94hlewvselxhj	cmrknuog001kb4hle3xbh9az9	cmrknut0y039h4hlekczcvqvm	COPY	\N	12000000	f	\N	2026-07-14 13:02:10.84	2026-07-14 13:02:10.84
cmrknuxes04td4hleg2id1q64	cmrknung7017n4hleej9wufua	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	14650000	f	\N	2026-07-14 13:02:10.852	2026-07-14 13:02:10.852
cmrknuxf404th4hle9odw0zwm	cmrknung7017n4hleej9wufua	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	12400000	f	\N	2026-07-14 13:02:10.864	2026-07-14 13:02:10.864
cmrknuxff04tl4hlejwct58c8	cmrknung7017n4hleej9wufua	cmrknut0y039h4hlekczcvqvm	COPY	\N	2800000	f	\N	2026-07-14 13:02:10.875	2026-07-14 13:02:10.875
cmrknuxfr04tp4hlesimozjnv	cmrknul2k00f94hle8edpqejf	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	14800000	f	\N	2026-07-14 13:02:10.887	2026-07-14 13:02:10.887
cmrknuxg204tt4hleljmbl8fs	cmrknul2k00f94hle8edpqejf	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	12400000	f	\N	2026-07-14 13:02:10.899	2026-07-14 13:02:10.899
cmrknuxge04tx4hlemm5nvlb5	cmrknul2k00f94hle8edpqejf	cmrknut0y039h4hlekczcvqvm	COPY	\N	2700000	f	\N	2026-07-14 13:02:10.911	2026-07-14 13:02:10.911
cmrknuxgr04u14hleak6q1qo4	cmrknuqa802fb4hlecn2zu5rr	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	14900000	f	\N	2026-07-14 13:02:10.923	2026-07-14 13:02:10.923
cmrknuxh304u54hlecqrlu884	cmrknuqa802fb4hlecn2zu5rr	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	12600000	f	\N	2026-07-14 13:02:10.935	2026-07-14 13:02:10.935
cmrknuxhe04u94hlew2vznsy5	cmrknuqa802fb4hlecn2zu5rr	cmrknut0y039h4hlekczcvqvm	COPY	\N	3500000	f	\N	2026-07-14 13:02:10.946	2026-07-14 13:02:10.946
cmrknuxhp04ud4hlek19v1c3w	cmrknuouh01vp4hle8wxziphl	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	14900000	f	\N	2026-07-14 13:02:10.958	2026-07-14 13:02:10.958
cmrknuxi104uh4hletjxm81yd	cmrknuouh01vp4hle8wxziphl	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	12300000	f	\N	2026-07-14 13:02:10.969	2026-07-14 13:02:10.969
cmrknuxic04ul4hles1ia1tys	cmrknuouh01vp4hle8wxziphl	cmrknut0y039h4hlekczcvqvm	COPY	\N	2700000	f	\N	2026-07-14 13:02:10.98	2026-07-14 13:02:10.98
cmrknuxin04up4hleq3ijagmt	cmrknuo9h01gv4hlexo1t13ns	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	10950000	f	\N	2026-07-14 13:02:10.991	2026-07-14 13:02:10.991
cmrknuxiy04ut4hlexuzarde8	cmrknuo9h01gv4hlexo1t13ns	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	8500000	f	\N	2026-07-14 13:02:11.003	2026-07-14 13:02:11.003
cmrknuxja04ux4hlef8yjafyq	cmrknuo9h01gv4hlexo1t13ns	cmrknut0y039h4hlekczcvqvm	COPY	\N	3000000	f	\N	2026-07-14 13:02:11.014	2026-07-14 13:02:11.014
cmrknuxjm04v14hlefjod4xzz	cmrknumj200xz4hle4fc7tcqd	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	15200000	f	\N	2026-07-14 13:02:11.026	2026-07-14 13:02:11.026
cmrknuxjx04v54hleqt5go2e9	cmrknumj200xz4hle4fc7tcqd	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	12750000	f	\N	2026-07-14 13:02:11.037	2026-07-14 13:02:11.037
cmrknuxk904v94hlepfzjnyf0	cmrknumj200xz4hle4fc7tcqd	cmrknut0y039h4hlekczcvqvm	COPY	\N	2800000	f	\N	2026-07-14 13:02:11.049	2026-07-14 13:02:11.049
cmrknuxkk04vd4hlegujazw0u	cmrknusw103834hle28m0hv9t	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	15980000	f	\N	2026-07-14 13:02:11.06	2026-07-14 13:02:11.06
cmrknuxkv04vh4hleh5xw9uz8	cmrknusw103834hle28m0hv9t	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	13400000	f	\N	2026-07-14 13:02:11.072	2026-07-14 13:02:11.072
cmrknuxl804vl4hleuhlx3vv4	cmrknusw103834hle28m0hv9t	cmrknut0y039h4hlekczcvqvm	COPY	\N	3200000	f	\N	2026-07-14 13:02:11.084	2026-07-14 13:02:11.084
cmrknuxlk04vp4hleh2xe5inc	cmrknunpn01aj4hlec9uqf21n	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	11350000	f	\N	2026-07-14 13:02:11.096	2026-07-14 13:02:11.096
cmrknuxlw04vt4hle2a5ox8r4	cmrknunpn01aj4hlec9uqf21n	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	9850000	f	\N	2026-07-14 13:02:11.108	2026-07-14 13:02:11.108
cmrknuxma04vx4hle6j0420gb	cmrknunpn01aj4hlec9uqf21n	cmrknut0y039h4hlekczcvqvm	COPY	\N	7600000	f	\N	2026-07-14 13:02:11.122	2026-07-14 13:02:11.122
cmrknuxmk04w14hlehl1k3qc1	cmrknural02q14hle9vr5m5o9	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	4300000	f	\N	2026-07-14 13:02:11.133	2026-07-14 13:02:11.133
cmrknuxmu04w54hlejonst9sr	cmrknural02q14hle9vr5m5o9	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	2950000	f	\N	2026-07-14 13:02:11.143	2026-07-14 13:02:11.143
cmrknuxn504w94hlee9y6fu77	cmrknural02q14hle9vr5m5o9	cmrknut0y039h4hlekczcvqvm	COPY	\N	1800000	f	\N	2026-07-14 13:02:11.154	2026-07-14 13:02:11.154
cmrknuxng04wd4hlej7vk9chu	cmrknuor001t14hle6pm0e1ec	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	3500000	f	\N	2026-07-14 13:02:11.164	2026-07-14 13:02:11.164
cmrknuxnr04wh4hleuqcn7w33	cmrknuor001t14hle6pm0e1ec	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	2550000	f	\N	2026-07-14 13:02:11.175	2026-07-14 13:02:11.175
cmrknuxo104wl4hlex41b97ze	cmrknuor001t14hle6pm0e1ec	cmrknut0y039h4hlekczcvqvm	COPY	\N	1700000	f	\N	2026-07-14 13:02:11.186	2026-07-14 13:02:11.186
cmrknuxoc04wp4hleqrvteo0o	cmrknukir009r4hlewgnx0n0z	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	3950000	f	\N	2026-07-14 13:02:11.196	2026-07-14 13:02:11.196
cmrknuxon04wt4hlejxd4dwqh	cmrknukir009r4hlewgnx0n0z	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	2800000	f	\N	2026-07-14 13:02:11.207	2026-07-14 13:02:11.207
cmrknuxox04wx4hleq6cxu73v	cmrknukir009r4hlewgnx0n0z	cmrknut0y039h4hlekczcvqvm	COPY	\N	1700000	f	\N	2026-07-14 13:02:11.218	2026-07-14 13:02:11.218
cmrknuxp704x14hleryytsczf	cmrknus1v02z14hleh3ioyxxq	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	13400000	f	\N	2026-07-14 13:02:11.227	2026-07-14 13:02:11.227
cmrknuxpi04x54hle2rjvu57u	cmrknus1v02z14hleh3ioyxxq	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	11350000	f	\N	2026-07-14 13:02:11.239	2026-07-14 13:02:11.239
cmrknuxpt04x94hlewljdv0sm	cmrknus1v02z14hleh3ioyxxq	cmrknut0y039h4hlekczcvqvm	COPY	\N	3400000	f	\N	2026-07-14 13:02:11.25	2026-07-14 13:02:11.25
cmrknuxq504xd4hle9zwzchh5	cmrknuoza01zn4hleklwdx8ju	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	11900000	f	\N	2026-07-14 13:02:11.262	2026-07-14 13:02:11.262
cmrknuxqg04xh4hledh0ccwqp	cmrknuoza01zn4hleklwdx8ju	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	9550000	f	\N	2026-07-14 13:02:11.273	2026-07-14 13:02:11.273
cmrknuxqs04xl4hle45pig5jr	cmrknuoza01zn4hleklwdx8ju	cmrknut0y039h4hlekczcvqvm	COPY	\N	3600000	f	\N	2026-07-14 13:02:11.285	2026-07-14 13:02:11.285
cmrknuxr404xp4hleameacnql	cmrknupj9027t4hle7p7wpqj7	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	14950000	f	\N	2026-07-14 13:02:11.296	2026-07-14 13:02:11.296
cmrknuxrg04xt4hlexqj23do4	cmrknupj9027t4hle7p7wpqj7	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	12300000	f	\N	2026-07-14 13:02:11.308	2026-07-14 13:02:11.308
cmrknuxrr04xx4hlel68dhtvl	cmrknupj9027t4hle7p7wpqj7	cmrknut0y039h4hlekczcvqvm	COPY	\N	9700000	f	\N	2026-07-14 13:02:11.319	2026-07-14 13:02:11.319
cmrknuxs404y14hlec852rstc	cmrknuovy01x54hlezhihgvxx	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	11300000	f	\N	2026-07-14 13:02:11.333	2026-07-14 13:02:11.333
cmrknuxsg04y54hleviimmj5r	cmrknuovy01x54hlezhihgvxx	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	7800000	f	\N	2026-07-14 13:02:11.344	2026-07-14 13:02:11.344
cmrknuxst04y94hle3ulle6i2	cmrknuovy01x54hlezhihgvxx	cmrknut0y039h4hlekczcvqvm	COPY	\N	2900000	f	\N	2026-07-14 13:02:11.357	2026-07-14 13:02:11.357
cmrknuxt504yd4hleb1ye576j	cmrknusw803854hlertklbqpd	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	9800000	f	\N	2026-07-14 13:02:11.369	2026-07-14 13:02:11.369
cmrknuxth04yh4hleegczeqkz	cmrknusw803854hlertklbqpd	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	7400000	f	\N	2026-07-14 13:02:11.381	2026-07-14 13:02:11.381
cmrknuxtt04yl4hleqbuehrjf	cmrknusw803854hlertklbqpd	cmrknut0y039h4hlekczcvqvm	COPY	\N	2900000	f	\N	2026-07-14 13:02:11.393	2026-07-14 13:02:11.393
cmrknuxu404yp4hlepq0m5rj2	cmrknus3x02zn4hle9485qdhb	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	3450000	f	\N	2026-07-14 13:02:11.405	2026-07-14 13:02:11.405
cmrknuxuh04yt4hlezr6cdvdr	cmrknus3x02zn4hle9485qdhb	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	2200000	f	\N	2026-07-14 13:02:11.417	2026-07-14 13:02:11.417
cmrknuxuv04yx4hlehhl5b91m	cmrknus3x02zn4hle9485qdhb	cmrknut0y039h4hlekczcvqvm	COPY	\N	1600000	f	\N	2026-07-14 13:02:11.431	2026-07-14 13:02:11.431
cmrknuxv704z14hlerc47yrmr	cmrknusd0032f4hlen5oyzfzd	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	13800000	f	\N	2026-07-14 13:02:11.443	2026-07-14 13:02:11.443
cmrknuxvj04z54hlekxcmf8g0	cmrknusd0032f4hlen5oyzfzd	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	10500000	f	\N	2026-07-14 13:02:11.455	2026-07-14 13:02:11.455
cmrknuxvw04z94hlekt9qzfex	cmrknusd0032f4hlen5oyzfzd	cmrknut0y039h4hlekczcvqvm	COPY	\N	2700000	f	\N	2026-07-14 13:02:11.468	2026-07-14 13:02:11.468
cmrknuxw804zd4hleixwqek4x	cmrknuoq001s94hleyl59xkq5	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	14700000	f	\N	2026-07-14 13:02:11.48	2026-07-14 13:02:11.48
cmrknuxwl04zh4hlec82bvanx	cmrknuoq001s94hleyl59xkq5	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	10950000	f	\N	2026-07-14 13:02:11.493	2026-07-14 13:02:11.493
cmrknuxwy04zl4hleztl8t05s	cmrknuoq001s94hleyl59xkq5	cmrknut0y039h4hlekczcvqvm	COPY	\N	2800000	f	\N	2026-07-14 13:02:11.506	2026-07-14 13:02:11.506
cmrknuxxc04zp4hle7kqdr8a3	cmrknulmp00pp4hlet3hpl7rg	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	14850000	f	\N	2026-07-14 13:02:11.52	2026-07-14 13:02:11.52
cmrknuxxp04zt4hleo689smwx	cmrknulmp00pp4hlet3hpl7rg	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	12300000	f	\N	2026-07-14 13:02:11.533	2026-07-14 13:02:11.533
cmrknuxy304zx4hlejmuy1hu4	cmrknulmp00pp4hlet3hpl7rg	cmrknut0y039h4hlekczcvqvm	COPY	\N	3300000	f	\N	2026-07-14 13:02:11.548	2026-07-14 13:02:11.548
cmrknuxyg05014hle319sqbth	cmrknurrb02vz4hlev0qzd26z	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	3550000	f	\N	2026-07-14 13:02:11.56	2026-07-14 13:02:11.56
cmrknuxys05054hlexhsx6z9c	cmrknurrb02vz4hlev0qzd26z	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	2500000	f	\N	2026-07-14 13:02:11.572	2026-07-14 13:02:11.572
cmrknuxz405094hle5np2cve2	cmrknurrb02vz4hlev0qzd26z	cmrknut0y039h4hlekczcvqvm	COPY	\N	1900000	f	\N	2026-07-14 13:02:11.584	2026-07-14 13:02:11.584
cmrknuxzg050d4hlepdpt5qoj	cmrknusk3034j4hle92gl94ax	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	3550000	f	\N	2026-07-14 13:02:11.596	2026-07-14 13:02:11.596
cmrknuxzs050h4hle8wcueuci	cmrknusk3034j4hle92gl94ax	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	2500000	f	\N	2026-07-14 13:02:11.608	2026-07-14 13:02:11.608
cmrknuy03050l4hlefv1sq9lm	cmrknusk3034j4hle92gl94ax	cmrknut0y039h4hlekczcvqvm	COPY	\N	1900000	f	\N	2026-07-14 13:02:11.62	2026-07-14 13:02:11.62
cmrknuy0f050p4hlenzqdltkm	cmrknuq5z02e34hlejp111l5i	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	3900000	f	\N	2026-07-14 13:02:11.632	2026-07-14 13:02:11.632
cmrknuy0r050t4hle712xsqug	cmrknuq5z02e34hlejp111l5i	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	2750000	f	\N	2026-07-14 13:02:11.643	2026-07-14 13:02:11.643
cmrknuy13050x4hlefazza4mv	cmrknuq5z02e34hlejp111l5i	cmrknut0y039h4hlekczcvqvm	COPY	\N	1800000	f	\N	2026-07-14 13:02:11.655	2026-07-14 13:02:11.655
cmrknuy1f05114hlem5rm1m8v	cmrknurtf02wl4hle9qhocufy	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	14900000	f	\N	2026-07-14 13:02:11.667	2026-07-14 13:02:11.667
cmrknuy1p05154hle5pdpd775	cmrknurtf02wl4hle9qhocufy	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	12500000	f	\N	2026-07-14 13:02:11.677	2026-07-14 13:02:11.677
cmrknuy2005194hleyc5ul332	cmrknurtf02wl4hle9qhocufy	cmrknut0y039h4hlekczcvqvm	COPY	\N	2800000	f	\N	2026-07-14 13:02:11.688	2026-07-14 13:02:11.688
cmrknuy2b051d4hlekubuf135	cmrknup0o020t4hle1ydhrjrc	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	10950000	f	\N	2026-07-14 13:02:11.699	2026-07-14 13:02:11.699
cmrknuy2n051h4hleqy3aqkoq	cmrknup0o020t4hle1ydhrjrc	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	8800000	f	\N	2026-07-14 13:02:11.711	2026-07-14 13:02:11.711
cmrknuy2y051l4hlefkkqi7ns	cmrknup0o020t4hle1ydhrjrc	cmrknut0y039h4hlekczcvqvm	COPY	\N	3100000	f	\N	2026-07-14 13:02:11.722	2026-07-14 13:02:11.722
cmrknuy39051p4hlethendq3u	cmrknum4400u94hle5h0g3m8t	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	10950000	f	\N	2026-07-14 13:02:11.733	2026-07-14 13:02:11.733
cmrknuy3k051t4hle1hmqn47a	cmrknum4400u94hle5h0g3m8t	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	8400000	f	\N	2026-07-14 13:02:11.745	2026-07-14 13:02:11.745
cmrknuy3w051x4hlet6bsry5j	cmrknum4400u94hle5h0g3m8t	cmrknut0y039h4hlekczcvqvm	COPY	\N	3300000	f	\N	2026-07-14 13:02:11.756	2026-07-14 13:02:11.756
cmrknuy4705214hlewf0m0gxb	cmrknumg700x94hle12jr1qh3	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	26000000	f	\N	2026-07-14 13:02:11.767	2026-07-14 13:02:11.767
cmrknuy4j05254hlequj02bcr	cmrknumg700x94hle12jr1qh3	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	23500000	f	\N	2026-07-14 13:02:11.779	2026-07-14 13:02:11.779
cmrknuy4u05294hlek5lz5pbf	cmrknumg700x94hle12jr1qh3	cmrknut0y039h4hlekczcvqvm	COPY	\N	19000000	f	\N	2026-07-14 13:02:11.79	2026-07-14 13:02:11.79
cmrknuy56052d4hlekp8pt7n9	cmrknurv002x14hlely1ge704	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	14950000	f	\N	2026-07-14 13:02:11.802	2026-07-14 13:02:11.802
cmrknuy5i052h4hleo0y81087	cmrknurv002x14hlely1ge704	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	12500000	f	\N	2026-07-14 13:02:11.814	2026-07-14 13:02:11.814
cmrknuy5s052l4hleerllhnsx	cmrknurv002x14hlely1ge704	cmrknut0y039h4hlekczcvqvm	COPY	\N	5400000	f	\N	2026-07-14 13:02:11.824	2026-07-14 13:02:11.824
cmrknuy63052p4hleu6xf3dg8	cmrknusvh037x4hleu56m0lj2	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	4200000	f	\N	2026-07-14 13:02:11.835	2026-07-14 13:02:11.835
cmrknuy6e052t4hlehlbde1dt	cmrknusvh037x4hleu56m0lj2	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	3100000	f	\N	2026-07-14 13:02:11.846	2026-07-14 13:02:11.846
cmrknuy6p052x4hlehks57nd8	cmrknusvh037x4hleu56m0lj2	cmrkbbzjk000amneoowf62wmn	COPY	\N	1900000	f	\N	2026-07-14 13:02:11.857	2026-07-14 13:02:11.857
cmrknuy7105314hlelardndx4	cmrknukuj00d34hleke6opuzt	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	16600000	f	با فریم صورتی	2026-07-14 13:02:11.869	2026-07-14 13:02:11.869
cmrknuy7c05354hlec17wdsiz	cmrknukuj00d34hleke6opuzt	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	14800000	f	با فریم صورتی	2026-07-14 13:02:11.88	2026-07-14 13:02:11.88
cmrknuy7n05394hleuieuh30y	cmrknukuj00d34hleke6opuzt	cmrknut0y039h4hlekczcvqvm	COPY	\N	12000000	f	با فریم صورتی	2026-07-14 13:02:11.891	2026-07-14 13:02:11.891
cmrknuy7z053d4hlew8ubasw0	cmrknusmh03574hleaoy1wipc	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	2200000	f	\N	2026-07-14 13:02:11.903	2026-07-14 13:02:11.903
cmrknuy8b053h4hlet41na5n2	cmrknusmh03574hleaoy1wipc	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	1600000	f	\N	2026-07-14 13:02:11.915	2026-07-14 13:02:11.915
cmrknuy8o053l4hlez7ipwu5j	cmrknusmh03574hleaoy1wipc	cmrkbbzjk000amneoowf62wmn	COPY	\N	900000	f	\N	2026-07-14 13:02:11.928	2026-07-14 13:02:11.928
cmrknuy8y053p4hlebjz6b4n3	cmrknusmp03594hleu7is34yw	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	2300000	f	\N	2026-07-14 13:02:11.939	2026-07-14 13:02:11.939
cmrknuy9b053t4hleqmye6vm0	cmrknusmp03594hleu7is34yw	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	1700000	f	\N	2026-07-14 13:02:11.951	2026-07-14 13:02:11.951
cmrknuy9m053x4hle63qgpf8h	cmrknusmp03594hleu7is34yw	cmrkbbzjk000amneoowf62wmn	COPY	\N	900000	f	\N	2026-07-14 13:02:11.962	2026-07-14 13:02:11.962
cmrknuy9w05414hlea52hohy1	cmrknusmw035b4hletixi9cgt	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	2600000	f	\N	2026-07-14 13:02:11.973	2026-07-14 13:02:11.973
cmrknuya805454hleg222bscd	cmrknusmw035b4hletixi9cgt	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	1700000	f	\N	2026-07-14 13:02:11.985	2026-07-14 13:02:11.985
cmrknuyak05494hleyrhznv4i	cmrknusmw035b4hletixi9cgt	cmrkbbzjk000amneoowf62wmn	COPY	\N	900000	f	\N	2026-07-14 13:02:11.996	2026-07-14 13:02:11.996
cmrknuyaw054d4hlevbfn7h6i	cmrknusn2035d4hlet253fmsf	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	2800000	f	\N	2026-07-14 13:02:12.008	2026-07-14 13:02:12.008
cmrknuyb8054h4hlezqhii6u2	cmrknusn2035d4hlet253fmsf	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	1900000	f	\N	2026-07-14 13:02:12.02	2026-07-14 13:02:12.02
cmrknuybj054l4hlecp8zf36q	cmrknusn2035d4hlet253fmsf	cmrkbbzjk000amneoowf62wmn	COPY	\N	1300000	f	\N	2026-07-14 13:02:12.032	2026-07-14 13:02:12.032
cmrknuybu054p4hlen7tvrwc5	cmrknusnf035h4hleqjp3o4de	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	3400000	f	\N	2026-07-14 13:02:12.043	2026-07-14 13:02:12.043
cmrknuyc6054t4hle73lk386z	cmrknusnf035h4hleqjp3o4de	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	2300000	f	\N	2026-07-14 13:02:12.054	2026-07-14 13:02:12.054
cmrknuyci054x4hle03qgk2y9	cmrknusnf035h4hleqjp3o4de	cmrkbbzjk000amneoowf62wmn	COPY	\N	1400000	f	\N	2026-07-14 13:02:12.067	2026-07-14 13:02:12.067
cmrknuyct05514hlekg1bm24s	cmrknusnn035j4hlemqflbimg	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	2100000	f	\N	2026-07-14 13:02:12.078	2026-07-14 13:02:12.078
cmrknuyd505554hle6jr00eiq	cmrknusnn035j4hlemqflbimg	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	1500000	f	\N	2026-07-14 13:02:12.089	2026-07-14 13:02:12.089
cmrknuydg05594hleb2l7qy2l	cmrknusnn035j4hlemqflbimg	cmrkbbzjk000amneoowf62wmn	COPY	\N	800000	f	\N	2026-07-14 13:02:12.101	2026-07-14 13:02:12.101
cmrknuydr055d4hleed8yu16i	cmrknusnt035l4hle78ull8hq	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	2500000	f	\N	2026-07-14 13:02:12.112	2026-07-14 13:02:12.112
cmrknuye3055h4hlemu22oei4	cmrknusnt035l4hle78ull8hq	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	1700000	f	\N	2026-07-14 13:02:12.123	2026-07-14 13:02:12.123
cmrknuyee055l4hlevhy7g7tv	cmrknusnt035l4hle78ull8hq	cmrkbbzjk000amneoowf62wmn	COPY	\N	1100000	f	\N	2026-07-14 13:02:12.134	2026-07-14 13:02:12.134
cmrknuyeq055p4hlereflnx8z	cmrknuso6035p4hleg1f5s7qh	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	3500000	f	\N	2026-07-14 13:02:12.146	2026-07-14 13:02:12.146
cmrknuyf2055t4hle3d57nzls	cmrknuso6035p4hleg1f5s7qh	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	2700000	f	\N	2026-07-14 13:02:12.158	2026-07-14 13:02:12.158
cmrknuyfd055x4hlepctwish0	cmrknuso6035p4hleg1f5s7qh	cmrkbbzjk000amneoowf62wmn	COPY	\N	1900000	f	\N	2026-07-14 13:02:12.169	2026-07-14 13:02:12.169
cmrknuyfo05614hlebkdpvxbg	cmrknusoj035t4hleeogpfz30	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	3500000	f	\N	2026-07-14 13:02:12.18	2026-07-14 13:02:12.18
cmrknuyfz05654hlepqrv5n9l	cmrknusoj035t4hleeogpfz30	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	2700000	f	\N	2026-07-14 13:02:12.191	2026-07-14 13:02:12.191
cmrknuygc05694hles88xj36p	cmrknusoj035t4hleeogpfz30	cmrkbbzjk000amneoowf62wmn	COPY	\N	1600000	f	\N	2026-07-14 13:02:12.204	2026-07-14 13:02:12.204
cmrknuygn056d4hlemo0omcc1	cmrknuswf03874hlem6077xbd	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	4100000	f	\N	2026-07-14 13:02:12.216	2026-07-14 13:02:12.216
cmrknuygx056h4hleqgi00qrp	cmrknuswf03874hlem6077xbd	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	3000000	f	\N	2026-07-14 13:02:12.225	2026-07-14 13:02:12.225
cmrknuyh8056l4hlebvbiinc7	cmrknuswf03874hlem6077xbd	cmrkbbzjk000amneoowf62wmn	COPY	\N	2100000	f	\N	2026-07-14 13:02:12.236	2026-07-14 13:02:12.236
cmrknuyhi056p4hle25tli2at	cmrknusop035v4hley486zzxx	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	3200000	f	\N	2026-07-14 13:02:12.246	2026-07-14 13:02:12.246
cmrknuyht056t4hle0h2w65dl	cmrknusop035v4hley486zzxx	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	2400000	f	\N	2026-07-14 13:02:12.257	2026-07-14 13:02:12.257
cmrknuyi4056x4hlezbnerxfe	cmrknusop035v4hley486zzxx	cmrkbbzjk000amneoowf62wmn	COPY	\N	1700000	f	\N	2026-07-14 13:02:12.269	2026-07-14 13:02:12.269
cmrknuyif05714hle4ysxy2z8	cmrknuswm03894hle861luy2i	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	3800000	f	\N	2026-07-14 13:02:12.28	2026-07-14 13:02:12.28
cmrknuyiq05754hle814b1gyl	cmrknuswm03894hle861luy2i	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	2800000	f	\N	2026-07-14 13:02:12.291	2026-07-14 13:02:12.291
cmrknuyj305794hle6urnyux7	cmrknuswm03894hle861luy2i	cmrkbbzjk000amneoowf62wmn	COPY	\N	1800000	f	\N	2026-07-14 13:02:12.303	2026-07-14 13:02:12.303
cmrknuyjf057d4hlenb4hj26c	cmrknusm403534hleg0ak87ub	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	4300000	f	\N	2026-07-14 13:02:12.315	2026-07-14 13:02:12.315
cmrknuyjq057h4hlex2quf7o3	cmrknusm403534hleg0ak87ub	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	3200000	f	\N	2026-07-14 13:02:12.326	2026-07-14 13:02:12.326
cmrknuyk1057l4hles5addmzw	cmrknusm403534hleg0ak87ub	cmrkbbzjk000amneoowf62wmn	COPY	\N	2500000	f	\N	2026-07-14 13:02:12.338	2026-07-14 13:02:12.338
cmrknuykd057p4hlewgy3amgh	cmrknuswu038b4hleatfopbt3	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	5900000	f	\N	2026-07-14 13:02:12.349	2026-07-14 13:02:12.349
cmrknuyko057t4hlej9k0ofp1	cmrknuswu038b4hleatfopbt3	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	4700000	f	\N	2026-07-14 13:02:12.36	2026-07-14 13:02:12.36
cmrknuykz057x4hlelngyyoqh	cmrknuswu038b4hleatfopbt3	cmrkbbzjk000amneoowf62wmn	COPY	\N	3500000	f	\N	2026-07-14 13:02:12.371	2026-07-14 13:02:12.371
cmrknuyla05814hlepfzjn6g8	cmrknusr0036l4hleezwyyicq	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	2100000	f	\N	2026-07-14 13:02:12.382	2026-07-14 13:02:12.382
cmrknuyll05854hle36r2t0hf	cmrknusr0036l4hleezwyyicq	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	1600000	f	\N	2026-07-14 13:02:12.393	2026-07-14 13:02:12.393
cmrknuylw05894hlep873tv5w	cmrknusr0036l4hleezwyyicq	cmrkbbzjk000amneoowf62wmn	COPY	\N	1000000	f	\N	2026-07-14 13:02:12.404	2026-07-14 13:02:12.404
cmrknuym8058d4hlew9z9kpt1	cmrknusxr038l4hlewlqsay4j	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	1400000	f	\N	2026-07-14 13:02:12.416	2026-07-14 13:02:12.416
cmrknuymj058h4hledvi4dlaq	cmrknusxr038l4hlewlqsay4j	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	900000	f	\N	2026-07-14 13:02:12.427	2026-07-14 13:02:12.427
cmrknuymu058l4hlea458kqd6	cmrknusxr038l4hlewlqsay4j	cmrkbbzjk000amneoowf62wmn	COPY	\N	500000	f	\N	2026-07-14 13:02:12.438	2026-07-14 13:02:12.438
cmrknuyn5058p4hle5r3zjmvn	cmrknusxk038j4hle6jj6osi9	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	3200000	f	\N	2026-07-14 13:02:12.449	2026-07-14 13:02:12.449
cmrknuyng058t4hleyt2b1qbx	cmrknusxk038j4hle6jj6osi9	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	2100000	f	\N	2026-07-14 13:02:12.46	2026-07-14 13:02:12.46
cmrknuynq058x4hledfwzpmjt	cmrknusxk038j4hle6jj6osi9	cmrkbbzjk000amneoowf62wmn	COPY	\N	1300000	f	\N	2026-07-14 13:02:12.47	2026-07-14 13:02:12.47
cmrknuyo105914hlepjn2dqwq	cmrknusxe038h4hle4ta0f80o	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	2400000	f	\N	2026-07-14 13:02:12.482	2026-07-14 13:02:12.482
cmrknuyoc05954hle6tymtwyq	cmrknusxe038h4hle4ta0f80o	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	1500000	f	\N	2026-07-14 13:02:12.492	2026-07-14 13:02:12.492
cmrknuyon05994hle8qeqwf5t	cmrknusxe038h4hle4ta0f80o	cmrkbbzjk000amneoowf62wmn	COPY	\N	900000	f	\N	2026-07-14 13:02:12.504	2026-07-14 13:02:12.504
cmrknuyp0059d4hleaxik2jdx	cmrknusx8038f4hleizavtaji	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	2400000	f	\N	2026-07-14 13:02:12.516	2026-07-14 13:02:12.516
cmrknuypb059h4hle15i112k3	cmrknusx8038f4hleizavtaji	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	1500000	f	\N	2026-07-14 13:02:12.527	2026-07-14 13:02:12.527
cmrknuypm059l4hle7z0gen50	cmrknusx8038f4hleizavtaji	cmrkbbzjk000amneoowf62wmn	COPY	\N	900000	f	\N	2026-07-14 13:02:12.538	2026-07-14 13:02:12.538
cmrknuypy059p4hleorukjkhw	cmrknusx0038d4hleov6tmfby	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	2000000	f	\N	2026-07-14 13:02:12.55	2026-07-14 13:02:12.55
cmrknuyq9059t4hlefoykvtdm	cmrknusx0038d4hleov6tmfby	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	1500000	f	\N	2026-07-14 13:02:12.562	2026-07-14 13:02:12.562
cmrknuyqk059x4hlea8fhyqct	cmrknusx0038d4hleov6tmfby	cmrkbbzjk000amneoowf62wmn	COPY	\N	900000	f	\N	2026-07-14 13:02:12.572	2026-07-14 13:02:12.572
cmrknuyqw05a14hlehn2w1afm	cmrknusyb038r4hle088k0w40	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	2700000	f	\N	2026-07-14 13:02:12.584	2026-07-14 13:02:12.584
cmrknuyr705a54hleedc3khf1	cmrknusyb038r4hle088k0w40	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	1900000	f	\N	2026-07-14 13:02:12.595	2026-07-14 13:02:12.595
cmrknuyri05a94hlenzkefg5e	cmrknusyb038r4hle088k0w40	cmrkbbzjk000amneoowf62wmn	COPY	\N	1100000	f	\N	2026-07-14 13:02:12.606	2026-07-14 13:02:12.606
cmrknuyrt05ad4hle11ynaoku	cmrknusy5038p4hle946qa1v3	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	4500000	f	\N	2026-07-14 13:02:12.617	2026-07-14 13:02:12.617
cmrknuys405ah4hlexw98yief	cmrknusy5038p4hle946qa1v3	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	3400000	f	\N	2026-07-14 13:02:12.629	2026-07-14 13:02:12.629
cmrknuysf05al4hlebw8jgvsa	cmrknusy5038p4hle946qa1v3	cmrkbbzjk000amneoowf62wmn	COPY	\N	2200000	f	\N	2026-07-14 13:02:12.64	2026-07-14 13:02:12.64
cmrknuysr05ap4hleei8r4guv	cmrknusyh038t4hlecmwekduf	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	4500000	f	\N	2026-07-14 13:02:12.651	2026-07-14 13:02:12.651
cmrknuyt305at4hle3tsj4jmr	cmrknusyh038t4hlecmwekduf	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	3600000	f	\N	2026-07-14 13:02:12.663	2026-07-14 13:02:12.663
cmrknuytd05ax4hlevscma11l	cmrknusyh038t4hlecmwekduf	cmrkbbzjk000amneoowf62wmn	COPY	\N	2800000	f	\N	2026-07-14 13:02:12.674	2026-07-14 13:02:12.674
cmrknuytu05b14hlech20gi56	cmrknusyo038v4hlesf7ff2hm	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	4500000	f	\N	2026-07-14 13:02:12.69	2026-07-14 13:02:12.69
cmrknuyuj05b54hleqogdbtgg	cmrknusyo038v4hlesf7ff2hm	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	3300000	f	\N	2026-07-14 13:02:12.715	2026-07-14 13:02:12.715
cmrknuyvk05b94hle3t6yp87v	cmrknusyo038v4hlesf7ff2hm	cmrkbbzjk000amneoowf62wmn	COPY	\N	2500000	f	\N	2026-07-14 13:02:12.748	2026-07-14 13:02:12.748
cmrknuywq05bd4hleqj24y6af	cmrknul5q00gl4hle3gl1cj9r	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	3950000	f	\N	2026-07-14 13:02:12.794	2026-07-14 13:02:12.794
cmrknuyxm05bh4hlejzb6rp8z	cmrknul5q00gl4hle3gl1cj9r	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	2850000	f	\N	2026-07-14 13:02:12.826	2026-07-14 13:02:12.826
cmrknuyy005bl4hlemobv44n4	cmrknul5q00gl4hle3gl1cj9r	cmrknut0y039h4hlekczcvqvm	COPY	\N	1700000	f	\N	2026-07-14 13:02:12.84	2026-07-14 13:02:12.84
cmrknuyyi05bp4hlentecocwd	cmrknukko00aj4hle515lwewj	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	3850000	f	\N	2026-07-14 13:02:12.858	2026-07-14 13:02:12.858
cmrknuyyz05bt4hle83iq5ess	cmrknukko00aj4hle515lwewj	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	2350000	f	\N	2026-07-14 13:02:12.875	2026-07-14 13:02:12.875
cmrknuyzj05bx4hleuphuexep	cmrknukko00aj4hle515lwewj	cmrknut0y039h4hlekczcvqvm	COPY	\N	1400000	f	\N	2026-07-14 13:02:12.895	2026-07-14 13:02:12.895
cmrknuz0305c14hlep6cbqu3w	cmrknushw033v4hletkgm2ouv	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	2450000	f	\N	2026-07-14 13:02:12.911	2026-07-14 13:02:12.911
cmrknuz0o05c54hletri8scdk	cmrknushw033v4hletkgm2ouv	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	1700000	f	\N	2026-07-14 13:02:12.936	2026-07-14 13:02:12.936
cmrknuz0y05c94hlet2hlrtbn	cmrknushw033v4hletkgm2ouv	cmrkbbzjk000amneoowf62wmn	COPY	\N	1200000	f	\N	2026-07-14 13:02:12.946	2026-07-14 13:02:12.946
cmrknuz1505cd4hlenqpbm9pu	cmrknul8c00i34hley56j21qf	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	5100000	f	\N	2026-07-14 13:02:12.954	2026-07-14 13:02:12.954
cmrknuz1h05ch4hleavru3kto	cmrknul8c00i34hley56j21qf	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	3900000	f	\N	2026-07-14 13:02:12.966	2026-07-14 13:02:12.966
cmrknuz1p05cl4hlehw9zwesc	cmrknul8c00i34hley56j21qf	cmrknut0y039h4hlekczcvqvm	COPY	\N	3000000	f	\N	2026-07-14 13:02:12.974	2026-07-14 13:02:12.974
cmrknuz1w05cp4hle1f19w2jh	cmrknusxy038n4hle157g9ifu	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	4500000	f	\N	2026-07-14 13:02:12.98	2026-07-14 13:02:12.98
cmrknuz2605ct4hlexxp3uv38	cmrknusxy038n4hle157g9ifu	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	3450000	f	\N	2026-07-14 13:02:12.991	2026-07-14 13:02:12.991
cmrknuz2g05cx4hleu0cts37q	cmrknusxy038n4hle157g9ifu	cmrkbbzjk000amneoowf62wmn	COPY	\N	2500000	f	\N	2026-07-14 13:02:13	2026-07-14 13:02:13
cmrknuz2o05d14hle6tbj0bc8	cmrknusc903274hle99wb20e9	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	3500000	f	\N	2026-07-14 13:02:13.008	2026-07-14 13:02:13.008
cmrknuz2x05d54hleozcm0xnm	cmrknusc903274hle99wb20e9	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	2600000	f	\N	2026-07-14 13:02:13.017	2026-07-14 13:02:13.017
cmrknuz3705d94hle4h027yu4	cmrknusc903274hle99wb20e9	cmrkbbzjk000amneoowf62wmn	COPY	\N	1500000	f	\N	2026-07-14 13:02:13.027	2026-07-14 13:02:13.027
cmrknuz3g05dd4hlezbqko4ay	cmrknusyu038x4hle19cwnvgc	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	14000000	f	\N	2026-07-14 13:02:13.036	2026-07-14 13:02:13.036
cmrknuz3n05dh4hlew6leiwcu	cmrknusyu038x4hle19cwnvgc	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	11000000	f	\N	2026-07-14 13:02:13.043	2026-07-14 13:02:13.043
cmrknuz3v05dl4hleko7jhkak	cmrknusyu038x4hle19cwnvgc	cmrknut0y039h4hlekczcvqvm	COPY	\N	5800000	f	\N	2026-07-14 13:02:13.051	2026-07-14 13:02:13.051
cmrknuz4005dp4hle2eounwjc	cmrknusfc03354hletvcgbdfn	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	3850000	f	\N	2026-07-14 13:02:13.057	2026-07-14 13:02:13.057
cmrknuz4705dt4hlezx7pgdon	cmrknusfc03354hletvcgbdfn	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	2700000	f	\N	2026-07-14 13:02:13.063	2026-07-14 13:02:13.063
cmrknuz4c05dx4hlenmbafnhe	cmrknusfc03354hletvcgbdfn	cmrknut0y039h4hlekczcvqvm	COPY	\N	1500000	f	\N	2026-07-14 13:02:13.068	2026-07-14 13:02:13.068
cmrknuz4i05e14hle4gbxk283	cmrknusz1038z4hleimlmm6jz	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	4450000	f	\N	2026-07-14 13:02:13.074	2026-07-14 13:02:13.074
cmrknuz4n05e54hlejy35ky1a	cmrknusz1038z4hleimlmm6jz	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	3450000	f	\N	2026-07-14 13:02:13.08	2026-07-14 13:02:13.08
cmrknuz4s05e94hle8uvkfy9n	cmrknusz1038z4hleimlmm6jz	cmrkbbzjk000amneoowf62wmn	COPY	\N	2100000	f	\N	2026-07-14 13:02:13.084	2026-07-14 13:02:13.084
cmrknuz4x05ed4hle4umbbnci	cmrknuoj801n54hle7clnsp84	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	15900000	f	\N	2026-07-14 13:02:13.089	2026-07-14 13:02:13.089
cmrknuz5305eh4hle92owdn9f	cmrknuoj801n54hle7clnsp84	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	12500000	f	\N	2026-07-14 13:02:13.095	2026-07-14 13:02:13.095
cmrknuz5905el4hlewfwk2xbc	cmrknuoj801n54hle7clnsp84	cmrknut0y039h4hlekczcvqvm	COPY	\N	7850000	f	\N	2026-07-14 13:02:13.101	2026-07-14 13:02:13.101
cmrknuz5e05ep4hlefmbflr0y	cmrknukiu009t4hlerhv6y22m	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	43950000	f	\N	2026-07-14 13:02:13.106	2026-07-14 13:02:13.106
cmrknuz5k05et4hlekong5btd	cmrknukiu009t4hlerhv6y22m	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	39600000	f	\N	2026-07-14 13:02:13.113	2026-07-14 13:02:13.113
cmrknuz5q05ex4hleqkq9lqa6	cmrknukiu009t4hlerhv6y22m	cmrknut0y039h4hlekczcvqvm	COPY	\N	33500000	f	\N	2026-07-14 13:02:13.118	2026-07-14 13:02:13.118
cmrknuz5v05f14hlevv7r6ts8	cmrknusma03554hle4uw4c3e2	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	5900000	f	\N	2026-07-14 13:02:13.124	2026-07-14 13:02:13.124
cmrknuz6105f54hlehvqd0n9c	cmrknusma03554hle4uw4c3e2	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	4400000	f	\N	2026-07-14 13:02:13.129	2026-07-14 13:02:13.129
cmrknuz6605f94hle49iwb8si	cmrknusma03554hle4uw4c3e2	cmrknut0y039h4hlekczcvqvm	COPY	\N	3500000	f	\N	2026-07-14 13:02:13.134	2026-07-14 13:02:13.134
cmrknuz6b05fd4hlea133o1nq	cmrknukcv00674hlej43clu7l	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	4600000	f	\N	2026-07-14 13:02:13.139	2026-07-14 13:02:13.139
cmrknuz6g05fh4hlebksfnz85	cmrknukcv00674hlej43clu7l	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	3300000	f	\N	2026-07-14 13:02:13.144	2026-07-14 13:02:13.144
cmrknuz6l05fl4hle30d8lcc0	cmrknukcv00674hlej43clu7l	cmrknut0y039h4hlekczcvqvm	COPY	\N	2200000	f	\N	2026-07-14 13:02:13.15	2026-07-14 13:02:13.15
cmrknuz6q05fp4hle8a4hfw3j	cmrknus7n030r4hle8r82udog	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	3800000	f	\N	2026-07-14 13:02:13.155	2026-07-14 13:02:13.155
cmrknuz6v05ft4hlebepxk7mt	cmrknus7n030r4hle8r82udog	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	2500000	f	\N	2026-07-14 13:02:13.159	2026-07-14 13:02:13.159
cmrknuz7005fx4hlez93me3fr	cmrknus7n030r4hle8r82udog	cmrknut0y039h4hlekczcvqvm	COPY	\N	1800000	f	\N	2026-07-14 13:02:13.165	2026-07-14 13:02:13.165
cmrknuz7505g14hlej1opc2c8	cmrknuome01ph4hlepy6pns1m	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	3950000	f	\N	2026-07-14 13:02:13.169	2026-07-14 13:02:13.169
cmrknuz7a05g54hle0xrdeis3	cmrknuome01ph4hlepy6pns1m	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	2800000	f	\N	2026-07-14 13:02:13.174	2026-07-14 13:02:13.174
cmrknuz7f05g94hleaidkehmr	cmrknuome01ph4hlepy6pns1m	cmrknut0y039h4hlekczcvqvm	COPY	\N	1900000	f	\N	2026-07-14 13:02:13.18	2026-07-14 13:02:13.18
cmrknuzmu05m94hlepqv2x3q4	cmrknut0a039d4hles56d0cdt	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	3700000	f	\N	2026-07-14 13:02:13.734	2026-07-14 13:02:13.734
cmrknuz7l05gd4hle0etdu4xi	cmrknurk502tv4hledarwecyu	cmrknut1e039j4hleuqvcm4l6	ORIGINAL	\N	14950000	f	در پشت با ال سی دی و شیشه لنز کامل 	2026-07-14 13:02:13.185	2026-07-14 13:02:13.185
cmrknuz7q05gh4hlebo9ou5up	cmrknurk502tv4hledarwecyu	cmrknut1e039j4hleuqvcm4l6	HIGH_COPY	\N	13800000	f	در پشت با ال سی دی و شیشه لنز کامل 	2026-07-14 13:02:13.19	2026-07-14 13:02:13.19
cmrknuz7v05gl4hlewrhl8jye	cmrknurk502tv4hledarwecyu	cmrknut1e039j4hleuqvcm4l6	COPY	\N	12000000	f	در پشت با ال سی دی و شیشه لنز کامل 	2026-07-14 13:02:13.196	2026-07-14 13:02:13.196
cmrknuz8005gp4hle1oqv3qwg	cmrknuots01v54hleihbam0j8	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	11950000	f	\N	2026-07-14 13:02:13.201	2026-07-14 13:02:13.201
cmrknuz8505gt4hle3yqnx1ay	cmrknuots01v54hleihbam0j8	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	9200000	f	\N	2026-07-14 13:02:13.206	2026-07-14 13:02:13.206
cmrknuz8a05gx4hle9sq66hvf	cmrknuots01v54hleihbam0j8	cmrknut0y039h4hlekczcvqvm	COPY	\N	3400000	f	\N	2026-07-14 13:02:13.211	2026-07-14 13:02:13.211
cmrknuz8g05h14hleo85a8ejj	cmrknuocd01i14hleqd0rgtvs	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	5600000	f	\N	2026-07-14 13:02:13.216	2026-07-14 13:02:13.216
cmrknuz8k05h54hlemmynuc57	cmrknuocd01i14hleqd0rgtvs	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	4400000	f	\N	2026-07-14 13:02:13.221	2026-07-14 13:02:13.221
cmrknuz8q05h94hlen0cwvb9h	cmrknuocd01i14hleqd0rgtvs	cmrknut0y039h4hlekczcvqvm	COPY	\N	3000000	f	\N	2026-07-14 13:02:13.226	2026-07-14 13:02:13.226
cmrknuz8v05hd4hleg5dmargx	cmrknuozg01zt4hlebqo5ndfn	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	3800000	f	A21s	2026-07-14 13:02:13.231	2026-07-14 13:02:13.231
cmrknuz9005hh4hlelti66a86	cmrknuozg01zt4hlebqo5ndfn	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	2500000	f	A21s	2026-07-14 13:02:13.236	2026-07-14 13:02:13.236
cmrknuz9605hl4hlei31aunsp	cmrknuozg01zt4hlebqo5ndfn	cmrknut0y039h4hlekczcvqvm	COPY	\N	1400000	f	A21s	2026-07-14 13:02:13.242	2026-07-14 13:02:13.242
cmrknuz9e05hp4hle42p301lt	cmrknukdp006h4hlew8pgxujy	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	5900000	f	\N	2026-07-14 13:02:13.25	2026-07-14 13:02:13.25
cmrknuz9n05ht4hlep9f7ljnl	cmrknukdp006h4hlew8pgxujy	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	4550000	f	\N	2026-07-14 13:02:13.259	2026-07-14 13:02:13.259
cmrknuz9y05hx4hlew9ewptoj	cmrknukdp006h4hlew8pgxujy	cmrknut0y039h4hlekczcvqvm	COPY	\N	3700000	f	\N	2026-07-14 13:02:13.271	2026-07-14 13:02:13.271
cmrknuzaa05i14hlehejh43vp	cmrknur2902nl4hlemy5ezwrb	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	2750000	f	A30	2026-07-14 13:02:13.283	2026-07-14 13:02:13.283
cmrknuzan05i54hlen5ey5i31	cmrknur2902nl4hlemy5ezwrb	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	1800000	f	A30	2026-07-14 13:02:13.295	2026-07-14 13:02:13.295
cmrknuzay05i94hlemzki85vv	cmrknur2902nl4hlemy5ezwrb	cmrkbbzjk000amneoowf62wmn	COPY	\N	1200000	f	A30	2026-07-14 13:02:13.306	2026-07-14 13:02:13.306
cmrknuzb905id4hlelnqwn6aa	cmrknuszr03974hle47hqgd17	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	12800000	f	\N	2026-07-14 13:02:13.318	2026-07-14 13:02:13.318
cmrknuzbl05ih4hlenblez09d	cmrknuszr03974hle47hqgd17	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	10900000	f	\N	2026-07-14 13:02:13.329	2026-07-14 13:02:13.329
cmrknuzbv05il4hletg7ol97m	cmrknuszr03974hle47hqgd17	cmrknut0y039h4hlekczcvqvm	COPY	\N	9500000	f	\N	2026-07-14 13:02:13.339	2026-07-14 13:02:13.339
cmrknuzc705ip4hlet23087f0	cmrknuszf03934hlekzcrisbt	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	4700000	f	\N	2026-07-14 13:02:13.351	2026-07-14 13:02:13.351
cmrknuzci05it4hle3vuy07fh	cmrknuszf03934hlekzcrisbt	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	3600000	f	\N	2026-07-14 13:02:13.362	2026-07-14 13:02:13.362
cmrknuzcs05ix4hledndupy5d	cmrknuszf03934hlekzcrisbt	cmrknut0y039h4hlekczcvqvm	COPY	\N	2500000	f	\N	2026-07-14 13:02:13.372	2026-07-14 13:02:13.372
cmrknuzd205j14hle9eys4y35	cmrknusz803914hle29zofxbs	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	6900000	f	\N	2026-07-14 13:02:13.383	2026-07-14 13:02:13.383
cmrknuzdd05j54hlewttobvtg	cmrknusz803914hle29zofxbs	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	5450000	f	\N	2026-07-14 13:02:13.393	2026-07-14 13:02:13.393
cmrknuzdp05j94hleivq4b4e9	cmrknusz803914hle29zofxbs	cmrknut0y039h4hlekczcvqvm	COPY	\N	4100000	f	\N	2026-07-14 13:02:13.405	2026-07-14 13:02:13.405
cmrknuze005jd4hle0zgkb9pq	cmrknuoen01j34hlefdj8ynuv	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	9500000	f	\N	2026-07-14 13:02:13.416	2026-07-14 13:02:13.416
cmrknuzec05jh4hlejie1132q	cmrknuoen01j34hlefdj8ynuv	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	7800000	f	\N	2026-07-14 13:02:13.428	2026-07-14 13:02:13.428
cmrknuzen05jl4hlenn8pme0m	cmrknuoen01j34hlefdj8ynuv	cmrknut0y039h4hlekczcvqvm	COPY	\N	5400000	f	\N	2026-07-14 13:02:13.439	2026-07-14 13:02:13.439
cmrknuzf005jp4hleu3b1xkbl	cmrknuoip01mp4hle4i7rw5fr	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	13300000	f	\N	2026-07-14 13:02:13.452	2026-07-14 13:02:13.452
cmrknuzfd05jt4hle5g29wbyo	cmrknuoip01mp4hle4i7rw5fr	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	10800000	f	\N	2026-07-14 13:02:13.466	2026-07-14 13:02:13.466
cmrknuzfp05jx4hlefwzak14j	cmrknuozg01zt4hlebqo5ndfn	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	2850000	f	\N	2026-07-14 13:02:13.478	2026-07-14 13:02:13.478
cmrknuzg205k14hlelcsmnwgv	cmrknuozg01zt4hlebqo5ndfn	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	1900000	f	\N	2026-07-14 13:02:13.49	2026-07-14 13:02:13.49
cmrknuzgf05k54hlet96u95gl	cmrknuozg01zt4hlebqo5ndfn	cmrkbbzjk000amneoowf62wmn	COPY	\N	1300000	f	\N	2026-07-14 13:02:13.503	2026-07-14 13:02:13.503
cmrknuzgu05k94hledx5w4pr1	cmrknunfk017h4hleirfcsgke	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	2600000	f	A01 core	2026-07-14 13:02:13.518	2026-07-14 13:02:13.518
cmrknuzh805kd4hle90tgtp50	cmrknunfk017h4hleirfcsgke	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	1500000	f	A01 core	2026-07-14 13:02:13.532	2026-07-14 13:02:13.532
cmrknuzhl05kh4hleibwcdftn	cmrknunfk017h4hleirfcsgke	cmrkbbzjk000amneoowf62wmn	COPY	\N	800000	f	A01 core	2026-07-14 13:02:13.545	2026-07-14 13:02:13.545
cmrknuzhy05kl4hletd2t52n3	cmrknuoq401sd4hleamdfg2qi	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	10900000	f	\N	2026-07-14 13:02:13.558	2026-07-14 13:02:13.558
cmrknuzi905kp4hle9a0hgnlg	cmrknuoq401sd4hleamdfg2qi	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	7200000	f	\N	2026-07-14 13:02:13.57	2026-07-14 13:02:13.57
cmrknuzim05kt4hleqmxdf1ba	cmrknuoq401sd4hleamdfg2qi	cmrknut0y039h4hlekczcvqvm	COPY	\N	5800000	f	\N	2026-07-14 13:02:13.582	2026-07-14 13:02:13.582
cmrknuzix05kx4hle03d4p5bq	cmrknukhb008f4hle5zvkb0x6	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	10900000	f	\N	2026-07-14 13:02:13.593	2026-07-14 13:02:13.593
cmrknuzj905l14hle1n1n5o6x	cmrknukhb008f4hle5zvkb0x6	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	7450000	f	\N	2026-07-14 13:02:13.605	2026-07-14 13:02:13.605
cmrknuzjm05l54hlelp6md1k5	cmrknukhb008f4hle5zvkb0x6	cmrknut0y039h4hlekczcvqvm	COPY	\N	4800000	f	\N	2026-07-14 13:02:13.618	2026-07-14 13:02:13.618
cmrknuzjz05l94hlevcoaewm1	cmrknuo0z01dd4hleg0f6nasn	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	10950000	f	\N	2026-07-14 13:02:13.631	2026-07-14 13:02:13.631
cmrknuzka05ld4hlerzqjtgyr	cmrknuo0z01dd4hleg0f6nasn	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	6900000	f	\N	2026-07-14 13:02:13.642	2026-07-14 13:02:13.642
cmrknuzkm05lh4hle8o05xc60	cmrknuo0z01dd4hleg0f6nasn	cmrknut0y039h4hlekczcvqvm	COPY	\N	4200000	f	\N	2026-07-14 13:02:13.654	2026-07-14 13:02:13.654
cmrknuzl005ll4hle5mqs4vvh	cmrknuspy03694hleoblpugdm	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	4900000	f	\N	2026-07-14 13:02:13.668	2026-07-14 13:02:13.668
cmrknuzlc05lp4hleqp199x00	cmrknuspy03694hleoblpugdm	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	3500000	f	\N	2026-07-14 13:02:13.68	2026-07-14 13:02:13.68
cmrknuzlm05lt4hleewovac0q	cmrknuspy03694hleoblpugdm	cmrkbbzjk000amneoowf62wmn	COPY	\N	2900000	f	\N	2026-07-14 13:02:13.691	2026-07-14 13:02:13.691
cmrknuzly05lx4hle5pwqkzfi	cmrknusxk038j4hle6jj6osi9	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	15600000	f	\N	2026-07-14 13:02:13.702	2026-07-14 13:02:13.702
cmrknuzm905m14hlesei6kc4s	cmrknusxk038j4hle6jj6osi9	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	12300000	f	\N	2026-07-14 13:02:13.713	2026-07-14 13:02:13.713
cmrknuzmi05m54hle3elefn32	cmrknusxk038j4hle6jj6osi9	cmrknut0y039h4hlekczcvqvm	COPY	\N	3500000	f	\N	2026-07-14 13:02:13.723	2026-07-14 13:02:13.723
cmrknuzn505md4hlepzfgor9k	cmrknut0a039d4hles56d0cdt	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	2850000	f	\N	2026-07-14 13:02:13.745	2026-07-14 13:02:13.745
cmrknuzng05mh4hlejtu1591e	cmrknut0a039d4hles56d0cdt	cmrknut0y039h4hlekczcvqvm	COPY	\N	1900000	f	\N	2026-07-14 13:02:13.756	2026-07-14 13:02:13.756
cmrknuznr05ml4hlev494wvni	cmrknusga033f4hlelpb105q2	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	12200000	f	\N	2026-07-14 13:02:13.767	2026-07-14 13:02:13.767
cmrknuzo205mp4hlel5pgr34q	cmrknusga033f4hlelpb105q2	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	9350000	f	\N	2026-07-14 13:02:13.778	2026-07-14 13:02:13.778
cmrknuzoc05mt4hle9ounx2zc	cmrknusga033f4hlelpb105q2	cmrknut0y039h4hlekczcvqvm	COPY	\N	4400000	f	\N	2026-07-14 13:02:13.788	2026-07-14 13:02:13.788
cmrknuzon05mx4hleg8e08bey	cmrknusqh036f4hleiqygbn34	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	12300000	f	\N	2026-07-14 13:02:13.8	2026-07-14 13:02:13.8
cmrknuzoy05n14hleovqb2hyc	cmrknusqh036f4hleiqygbn34	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	9550000	f	\N	2026-07-14 13:02:13.811	2026-07-14 13:02:13.811
cmrknuzp905n54hlet27iqj44	cmrknusqh036f4hleiqygbn34	cmrknut0y039h4hlekczcvqvm	COPY	\N	3900000	f	\N	2026-07-14 13:02:13.821	2026-07-14 13:02:13.821
cmrknuzpk05n94hlevcr040x6	cmrknut0g039f4hle677spnqb	cmrkbbzjk000amneoowf62wmn	ORIGINAL	\N	5500000	f	\N	2026-07-14 13:02:13.833	2026-07-14 13:02:13.833
cmrknuzpv05nd4hle41y0xj3i	cmrknut0g039f4hle677spnqb	cmrkbbzjk000amneoowf62wmn	HIGH_COPY	\N	4200000	f	\N	2026-07-14 13:02:13.843	2026-07-14 13:02:13.843
cmrknuzq605nh4hlek1f48h4g	cmrknut0g039f4hle677spnqb	cmrkbbzjk000amneoowf62wmn	COPY	\N	3500000	f	\N	2026-07-14 13:02:13.854	2026-07-14 13:02:13.854
cmrknuzqh05nl4hle07i964oy	cmrknuoh801ld4hlebivzzopl	cmrknut0y039h4hlekczcvqvm	ORIGINAL	\N	10950000	f	\N	2026-07-14 13:02:13.865	2026-07-14 13:02:13.865
cmrknuzqr05np4hlev5m8uupe	cmrknuoh801ld4hlebivzzopl	cmrknut0y039h4hlekczcvqvm	HIGH_COPY	\N	8400000	f	\N	2026-07-14 13:02:13.875	2026-07-14 13:02:13.875
cmrknuzr205nt4hletp00s21h	cmrknuoh801ld4hlebivzzopl	cmrknut0y039h4hlekczcvqvm	COPY	\N	3500000	f	\N	2026-07-14 13:02:13.886	2026-07-14 13:02:13.886
\.


--
-- Data for Name: part_requests; Type: TABLE DATA; Schema: public; Owner: bartar_user
--

COPY public.part_requests (id, "repairTicketId", "partId", quality, brand, model, status, "announcedPrice", "depositAmount", "isTest", description, "createdById", "createdAt", "updatedAt", "deletedAt", quantity, "receptionNumber", "modelId") FROM stdin;
cmrkcr0bd002mv0qq0rvkqnhz	\N	cmrkbsj4y0000v0qqw5o886a9	ORIGINAL	Samsung	a16	RETURNED	5000000	0	f	\N	cmrizjjwb0019gmio8se0jmba	2026-07-14 07:51:12.217	2026-07-14 07:52:47.763	\N	1	2056	cmrkbxs700015v0qqtfqefy5a
cmrjt28fl0002jgwxknfyfhwt	\N	cmrjt28f50000jgwxr96jhrgf	ORIGINAL	بب	بب	PURCHASING	4000000	0	f	\N	cmrizjjwb0019gmio8se0jmba	2026-07-13 22:40:03.633	2026-07-13 22:40:54.3	\N	1	544545	\N
cmrkbbzk9000cmneoxa5m6wyp	\N	cmrkbbzjk000amneoowf62wmn	ORIGINAL	Samsung	Galaxy A52	PURCHASING	25000000	0	f	\N	cmrizjjwb0019gmio8se0jmba	2026-07-14 07:11:31.785	2026-07-14 07:11:44.877	\N	1	10548	cmrkbazc30003mneojccqn9zn
cmrkbsj5r0002v0qq19kkmynj	\N	cmrkbsj4y0000v0qqw5o886a9	ORIGINAL	Samsung	Galaxy A52	RETURNED	52000000	0	f	\N	cmrizjjwb0019gmio8se0jmba	2026-07-14 07:24:23.679	2026-07-14 07:27:26.126	\N	1	5812	cmrkbazc30003mneojccqn9zn
cmrkbxse1001av0qq2iwql35v	\N	cmrkbsj4y0000v0qqw5o886a9	ORIGINAL	Samsung	a16	PURCHASED	8000000	0	f	\N	cmrizjjwb0019gmio8se0jmba	2026-07-14 07:28:28.921	2026-07-14 07:28:58.944	\N	1	2512	cmrkbxs700015v0qqtfqefy5a
cmrkcpilv0027v0qqsgolo27p	\N	cmrkbbzjk000amneoowf62wmn	ORIGINAL	Samsung	Galaxy A52	WAITING_PURCHASE	2600000	0	f	\N	cmrizjjwb0019gmio8se0jmba	2026-07-14 07:50:02.611	2026-07-14 07:50:14.891	\N	1	5023	cmrkbazc30003mneojccqn9zn
\.


--
-- Data for Name: parts; Type: TABLE DATA; Schema: public; Owner: bartar_user
--

COPY public.parts (id, name, category, "createdAt", "updatedAt", "deletedAt") FROM stdin;
cmrjt28f50000jgwxr96jhrgf	ببب	\N	2026-07-13 22:40:03.617	2026-07-13 22:40:03.617	\N
cmrkbbzjk000amneoowf62wmn	باتری	\N	2026-07-14 07:11:31.76	2026-07-14 07:11:31.76	\N
cmrkbsj4y0000v0qqw5o886a9	ال سی دی	\N	2026-07-14 07:24:23.65	2026-07-14 07:24:23.65	\N
cmrknut0y039h4hlekczcvqvm	ال‌سی‌دی	\N	2026-07-14 13:02:05.171	2026-07-14 13:02:05.171	\N
cmrknut16039i4hlen5tdjud5	شارژر	\N	2026-07-14 13:02:05.179	2026-07-14 13:02:05.179	\N
cmrknut1e039j4hleuqvcm4l6	درب پشت	\N	2026-07-14 13:02:05.186	2026-07-14 13:02:05.186	\N
cmrknut1l039k4hle0hr62dc5	اسپیکر	\N	2026-07-14 13:02:05.193	2026-07-14 13:02:05.193	\N
cmrknut1s039l4hleoux1njr0	میکروفون	\N	2026-07-14 13:02:05.2	2026-07-14 13:02:05.2	\N
cmrknut1z039m4hlefw6bjkj3	دوربین	\N	2026-07-14 13:02:05.207	2026-07-14 13:02:05.207	\N
cmrknut26039n4hlefei4v2w9	برد	\N	2026-07-14 13:02:05.215	2026-07-14 13:02:05.215	\N
\.


--
-- Data for Name: permissions; Type: TABLE DATA; Schema: public; Owner: bartar_user
--

COPY public.permissions (id, code, "group", description, "createdAt", "updatedAt") FROM stdin;
cmrizjij60000gmioorc6ppzy	LOGIN	Authentication	\N	2026-07-13 08:53:41.394	2026-07-13 11:29:58.891
cmrizjijl0001gmiofdrcjubm	LOGOUT	Authentication	\N	2026-07-13 08:53:41.41	2026-07-13 11:29:58.898
cmrizjijp0002gmiofzf7yzlb	CREATE_REPAIR	Repair	\N	2026-07-13 08:53:41.414	2026-07-13 11:29:58.9
cmrizjiju0003gmiok6ik9pay	EDIT_REPAIR	Repair	\N	2026-07-13 08:53:41.418	2026-07-13 11:29:58.903
cmrizjijy0004gmioyue6oem9	VIEW_REPAIR	Repair	\N	2026-07-13 08:53:41.423	2026-07-13 11:29:58.905
cmrizjik30005gmiomd3k5vbg	DELETE_REPAIR	Repair	\N	2026-07-13 08:53:41.427	2026-07-13 11:29:58.907
cmrizjik70006gmiolzjtjrbl	CREATE_PART_REQUEST	Part Request	\N	2026-07-13 08:53:41.431	2026-07-13 11:29:58.909
cmrizjikc0007gmiotrvwdodn	EDIT_PART_REQUEST	Part Request	\N	2026-07-13 08:53:41.436	2026-07-13 11:29:58.911
cmrizjikh0008gmio9ozoaft7	DELETE_PART_REQUEST	Part Request	\N	2026-07-13 08:53:41.441	2026-07-13 11:29:58.914
cmrizjikm0009gmiomo7askru	VIEW_PART_REQUEST	Part Request	\N	2026-07-13 08:53:41.446	2026-07-13 11:29:58.916
cmrizjikq000agmio6y996gng	CHANGE_STATUS	Part Request	\N	2026-07-13 08:53:41.451	2026-07-13 11:29:58.918
cmrizjiku000bgmiox59z9bi4	START_PURCHASE	Purchase	\N	2026-07-13 08:53:41.454	2026-07-13 11:29:58.921
cmrizjiky000cgmiozippv960	REGISTER_PURCHASE	Purchase	\N	2026-07-13 08:53:41.458	2026-07-13 11:29:58.923
cmrizjil2000dgmio5593xn2k	EDIT_PURCHASE	Purchase	\N	2026-07-13 08:53:41.463	2026-07-13 11:29:58.925
cmrizjil6000egmioey1sdao2	RETURN_PURCHASE	Purchase	\N	2026-07-13 08:53:41.466	2026-07-13 11:29:58.927
cmrizjila000fgmiovim2uaau	NOT_FOUND	Purchase	\N	2026-07-13 08:53:41.47	2026-07-13 11:29:58.929
cmrizjile000ggmio0tqqwbvp	VIEW_PRICE	Pricing	\N	2026-07-13 08:53:41.474	2026-07-13 11:29:58.932
cmrizjili000hgmionkimunjh	EDIT_PRICE	Pricing	\N	2026-07-13 08:53:41.478	2026-07-13 11:29:58.935
cmrizjilm000igmiobbvrnu3w	VIEW_PRICE_HISTORY	Pricing	\N	2026-07-13 08:53:41.482	2026-07-13 11:29:58.938
cmrizjilq000jgmio88sox90h	CREATE_VENDOR	Vendor	\N	2026-07-13 08:53:41.486	2026-07-13 11:29:58.941
cmrizjilu000kgmiois383r0m	EDIT_VENDOR	Vendor	\N	2026-07-13 08:53:41.49	2026-07-13 11:29:58.943
cmrizjily000lgmioo9a3uent	DELETE_VENDOR	Vendor	\N	2026-07-13 08:53:41.494	2026-07-13 11:29:58.947
cmrizjim2000mgmioxpa350kk	VIEW_VENDOR	Vendor	\N	2026-07-13 08:53:41.498	2026-07-13 11:29:58.95
cmrizjim6000ngmiojjh6ce7r	CREATE_USER	Users	\N	2026-07-13 08:53:41.502	2026-07-13 11:29:58.955
cmrizjima000ogmioouekzad6	EDIT_USER	Users	\N	2026-07-13 08:53:41.506	2026-07-13 11:29:58.958
cmrizjime000pgmio6cyqiers	DELETE_USER	Users	\N	2026-07-13 08:53:41.51	2026-07-13 11:29:58.962
cmrizjimh000qgmiosjb2a4ut	VIEW_USER	Users	\N	2026-07-13 08:53:41.513	2026-07-13 11:29:58.966
cmrizjimk000rgmiok8mtmbn6	CREATE_ROLE	Roles	\N	2026-07-13 08:53:41.516	2026-07-13 11:29:58.97
cmrizjimo000sgmioxn2ggl6p	EDIT_ROLE	Roles	\N	2026-07-13 08:53:41.52	2026-07-13 11:29:58.973
cmrizjimr000tgmioqmiw5154	DELETE_ROLE	Roles	\N	2026-07-13 08:53:41.524	2026-07-13 11:29:58.976
cmrizjimv000ugmionkc44xnp	ASSIGN_ROLE	Roles	\N	2026-07-13 08:53:41.528	2026-07-13 11:29:58.98
cmrizjimz000vgmiopi5t5pbl	ASSIGN_PERMISSION	Permission	\N	2026-07-13 08:53:41.531	2026-07-13 11:29:58.983
cmrizjin2000wgmioai7plt6a	VIEW_ACTIVITY_LOG	Logs	\N	2026-07-13 08:53:41.534	2026-07-13 11:29:58.987
cmrizjin6000xgmiobvdee0wp	VIEW_SYSTEM_LOG	Logs	\N	2026-07-13 08:53:41.538	2026-07-13 11:29:58.991
cmrizjina000ygmio9324mxln	VIEW_REPORTS	Reports	\N	2026-07-13 08:53:41.542	2026-07-13 11:29:58.995
cmrizjind000zgmiompk5keax	EXPORT_REPORTS	Reports	\N	2026-07-13 08:53:41.546	2026-07-13 11:29:58.998
cmrizjinh0010gmio0c9uzwor	VIEW_SETTINGS	Settings	\N	2026-07-13 08:53:41.549	2026-07-13 11:29:59.002
cmrizjinl0011gmioc3gqwqda	EDIT_SETTINGS	Settings	\N	2026-07-13 08:53:41.553	2026-07-13 11:29:59.006
\.


--
-- Data for Name: price_histories; Type: TABLE DATA; Schema: public; Owner: bartar_user
--

COPY public.price_histories (id, "partId", "purchaseId", type, price, "recordedAt", "createdAt", "modelId", quality) FROM stdin;
cmrkbu7vh000rv0qqrt3pk0ji	cmrkbsj4y0000v0qqw5o886a9	cmrkbu7rs000nv0qqufs79xrn	BUY	48000000	2026-07-14 07:25:42.365	2026-07-14 07:25:42.365	cmrkbazc30003mneojccqn9zn	ORIGINAL
cmrkbu7wh000vv0qqpgrddygf	cmrkbsj4y0000v0qqw5o886a9	cmrkbu7rs000nv0qqufs79xrn	SELL	62400000	2026-07-14 07:25:42.401	2026-07-14 07:25:42.401	cmrkbazc30003mneojccqn9zn	ORIGINAL
cmrkbyfkp001wv0qq0gw8l4sy	cmrkbsj4y0000v0qqw5o886a9	cmrkbyfiy001sv0qqjiresexo	BUY	9000000	2026-07-14 07:28:58.969	2026-07-14 07:28:58.969	cmrkbxs700015v0qqtfqefy5a	ORIGINAL
cmrkbyfln0020v0qqx7mmvw1b	cmrkbsj4y0000v0qqw5o886a9	cmrkbyfiy001sv0qqjiresexo	SELL	11700000	2026-07-14 07:28:59.003	2026-07-14 07:28:59.003	cmrkbxs700015v0qqtfqefy5a	ORIGINAL
cmrkcsm0m0039v0qqwluh2czx	cmrkbsj4y0000v0qqw5o886a9	cmrkcslyv0033v0qqqqoej985	BUY	6000000	2026-07-14 07:52:26.999	2026-07-14 07:52:26.999	cmrkbxs700015v0qqtfqefy5a	ORIGINAL
cmrkcsm1h003dv0qq8n9xyrzz	cmrkbsj4y0000v0qqw5o886a9	cmrkcslyv0033v0qqqqoej985	SELL	7800000	2026-07-14 07:52:27.029	2026-07-14 07:52:27.029	cmrkbxs700015v0qqtfqefy5a	ORIGINAL
cmrknut34039r4hleke9eep4x	cmrknut1e039j4hleuqvcm4l6	\N	SELL	1980000	2026-06-14 11:22:46.188	2026-07-14 13:02:05.248	cmrknuowk01xn4hleeayo14lf	ORIGINAL
cmrknut3l039v4hlev5b35pnk	cmrknut1e039j4hleuqvcm4l6	\N	SELL	1460000	2026-06-14 11:22:46.188	2026-07-14 13:02:05.265	cmrknuowk01xn4hleeayo14lf	HIGH_COPY
cmrknut3z039z4hle35rpaeyx	cmrknut1e039j4hleuqvcm4l6	\N	SELL	550000	2026-06-14 11:22:46.188	2026-07-14 13:02:05.279	cmrknuowk01xn4hleeayo14lf	COPY
cmrknut4c03a34hlex90pk59b	cmrknut0y039h4hlekczcvqvm	\N	SELL	3280000	2026-06-14 12:15:58.413	2026-07-14 13:02:05.292	cmrknurun02wx4hlefzl620dj	ORIGINAL
cmrknut4o03a74hlecuii7nfo	cmrknut0y039h4hlekczcvqvm	\N	SELL	2300000	2026-06-14 12:15:58.413	2026-07-14 13:02:05.304	cmrknurun02wx4hlefzl620dj	HIGH_COPY
cmrknut5003ab4hlexr1wg26e	cmrknut0y039h4hlekczcvqvm	\N	SELL	1700000	2026-06-14 12:15:58.413	2026-07-14 13:02:05.317	cmrknurun02wx4hlefzl620dj	COPY
cmrknut5c03af4hlethc4nobe	cmrkbbzjk000amneoowf62wmn	\N	SELL	12000000	2026-06-30 07:42:09.106	2026-07-14 13:02:05.328	cmrknusde032j4hlenxdh2yqj	ORIGINAL
cmrknut5o03aj4hle0xdoid0g	cmrknut1e039j4hleuqvcm4l6	\N	SELL	1980000	2026-06-21 04:28:10.265	2026-07-14 13:02:05.34	cmrknuoq001s94hleyl59xkq5	ORIGINAL
cmrknut5z03an4hlei3hrtj4t	cmrknut1e039j4hleuqvcm4l6	\N	SELL	1200000	2026-06-21 04:28:10.265	2026-07-14 13:02:05.352	cmrknuoq001s94hleyl59xkq5	HIGH_COPY
cmrknut6b03ar4hle0ap4paa8	cmrknut1e039j4hleuqvcm4l6	\N	SELL	600	2026-06-21 04:28:10.265	2026-07-14 13:02:05.363	cmrknuoq001s94hleyl59xkq5	COPY
cmrknut6m03av4hledffjltij	cmrkbbzjk000amneoowf62wmn	\N	SELL	4320000	2026-06-21 04:30:45.753	2026-07-14 13:02:05.374	cmrknuog001kb4hle3xbh9az9	ORIGINAL
cmrknut6w03az4hlee4kafrfn	cmrkbbzjk000amneoowf62wmn	\N	SELL	3750000	2026-06-21 04:30:45.753	2026-07-14 13:02:05.385	cmrknuog001kb4hle3xbh9az9	HIGH_COPY
cmrknut7803b34hle5cdj6k4t	cmrkbbzjk000amneoowf62wmn	\N	SELL	2900000	2026-06-21 04:30:45.753	2026-07-14 13:02:05.396	cmrknuog001kb4hle3xbh9az9	COPY
cmrknut7i03b74hlem4karrqo	cmrknut0y039h4hlekczcvqvm	\N	SELL	13850000	2026-06-21 04:31:58.705	2026-07-14 13:02:05.407	cmrknuoyb01yx4hlepbqolnr3	ORIGINAL
cmrknut7u03bb4hlen7675oho	cmrknut0y039h4hlekczcvqvm	\N	SELL	11300000	2026-06-21 04:31:58.705	2026-07-14 13:02:05.418	cmrknuoyb01yx4hlepbqolnr3	HIGH_COPY
cmrknut8503bf4hle2wrokaut	cmrknut0y039h4hlekczcvqvm	\N	SELL	2900000	2026-06-21 04:31:58.705	2026-07-14 13:02:05.429	cmrknuoyb01yx4hlepbqolnr3	COPY
cmrknut8h03bj4hle8pp6v7vm	cmrknut0y039h4hlekczcvqvm	\N	SELL	5980000	2026-06-21 04:49:50.154	2026-07-14 13:02:05.441	cmrknuk45002b4hle2tooy7xy	ORIGINAL
cmrknut8s03bn4hler772xtn9	cmrknut0y039h4hlekczcvqvm	\N	SELL	3350000	2026-06-21 04:49:50.154	2026-07-14 13:02:05.452	cmrknuk45002b4hle2tooy7xy	HIGH_COPY
cmrknut9303br4hledvcoe93s	cmrknut0y039h4hlekczcvqvm	\N	SELL	1500000	2026-06-21 04:49:50.154	2026-07-14 13:02:05.463	cmrknuk45002b4hle2tooy7xy	COPY
cmrknut9f03bv4hleluxyimm3	cmrknut16039i4hlen5tdjud5	\N	SELL	500000	2026-06-21 04:51:14.501	2026-07-14 13:02:05.475	cmrknuk45002b4hle2tooy7xy	ORIGINAL
cmrknut9q03bz4hlehaemsjs3	cmrknut16039i4hlen5tdjud5	\N	SELL	850000	2026-06-21 04:51:14.501	2026-07-14 13:02:05.486	cmrknuk45002b4hle2tooy7xy	HIGH_COPY
cmrknuta003c34hleqt2ri66l	cmrknut16039i4hlen5tdjud5	\N	SELL	1470000	2026-06-21 04:51:14.501	2026-07-14 13:02:05.496	cmrknuk45002b4hle2tooy7xy	COPY
cmrknutac03c74hleo6by6jau	cmrkbbzjk000amneoowf62wmn	\N	SELL	2440000	2026-06-21 05:18:08.658	2026-07-14 13:02:05.508	cmrknuorx01tj4hlebwnvqk6a	ORIGINAL
cmrknutao03cb4hlelp5d1sv4	cmrkbbzjk000amneoowf62wmn	\N	SELL	1780000	2026-06-21 05:18:08.658	2026-07-14 13:02:05.52	cmrknuorx01tj4hlebwnvqk6a	HIGH_COPY
cmrknutaz03cf4hledyry0hal	cmrkbbzjk000amneoowf62wmn	\N	SELL	1100000	2026-06-21 05:18:08.658	2026-07-14 13:02:05.531	cmrknuorx01tj4hlebwnvqk6a	COPY
cmrknutba03cj4hledlx6r9g9	cmrknut0y039h4hlekczcvqvm	\N	SELL	9880000	2026-06-21 06:06:58.033	2026-07-14 13:02:05.542	cmrknuklm00at4hletkkael85	ORIGINAL
cmrknutbm03cn4hlea5san96m	cmrknut0y039h4hlekczcvqvm	\N	SELL	7500000	2026-06-21 06:06:58.033	2026-07-14 13:02:05.554	cmrknuklm00at4hletkkael85	HIGH_COPY
cmrknutby03cr4hlegc9h61pp	cmrknut0y039h4hlekczcvqvm	\N	SELL	2900000	2026-06-21 06:06:58.033	2026-07-14 13:02:05.566	cmrknuklm00at4hletkkael85	COPY
cmrknutc903cv4hle6k6v7zbb	cmrkbbzjk000amneoowf62wmn	\N	SELL	3820000	2026-06-21 06:07:32.764	2026-07-14 13:02:05.577	cmrknuos101tn4hle2go8iozz	ORIGINAL
cmrknutck03cz4hle6pqn6civ	cmrkbbzjk000amneoowf62wmn	\N	SELL	2980000	2026-06-21 06:07:32.764	2026-07-14 13:02:05.588	cmrknuos101tn4hle2go8iozz	HIGH_COPY
cmrknutcv03d34hleik1dpj2r	cmrkbbzjk000amneoowf62wmn	\N	SELL	2500000	2026-06-21 06:07:32.764	2026-07-14 13:02:05.599	cmrknuos101tn4hle2go8iozz	COPY
cmrknutd603d74hlef5axxxvt	cmrknut0y039h4hlekczcvqvm	\N	SELL	3980000	2026-06-21 06:56:43.695	2026-07-14 13:02:05.61	cmrknuma100vr4hle06yrtrzv	ORIGINAL
cmrknutdh03db4hle1yy9dso2	cmrknut0y039h4hlekczcvqvm	\N	SELL	2560000	2026-06-21 06:56:43.695	2026-07-14 13:02:05.621	cmrknuma100vr4hle06yrtrzv	HIGH_COPY
cmrknutds03df4hlew830uo77	cmrknut0y039h4hlekczcvqvm	\N	SELL	1400000	2026-06-21 06:56:43.695	2026-07-14 13:02:05.632	cmrknuma100vr4hle06yrtrzv	COPY
cmrknute303dj4hle4ysw34bl	cmrkbbzjk000amneoowf62wmn	\N	SELL	3950000	2026-06-21 06:58:15.782	2026-07-14 13:02:05.643	cmrknurtf02wl4hle9qhocufy	ORIGINAL
cmrknutef03dn4hleocvskwpu	cmrkbbzjk000amneoowf62wmn	\N	SELL	2880000	2026-06-21 06:58:15.782	2026-07-14 13:02:05.655	cmrknurtf02wl4hle9qhocufy	HIGH_COPY
cmrknuteq03dr4hles9fkigxn	cmrkbbzjk000amneoowf62wmn	\N	SELL	2500000	2026-06-21 06:58:15.782	2026-07-14 13:02:05.666	cmrknurtf02wl4hle9qhocufy	COPY
cmrknutf003dv4hlerkrtl5k8	cmrknut0y039h4hlekczcvqvm	\N	SELL	15380000	2026-06-21 07:11:07.761	2026-07-14 13:02:05.676	cmrknuqre02kf4hlefzxppos4	ORIGINAL
cmrknutfb03dz4hlei2l8o0u4	cmrknut0y039h4hlekczcvqvm	\N	SELL	12400000	2026-06-21 07:11:07.761	2026-07-14 13:02:05.687	cmrknuqre02kf4hlefzxppos4	HIGH_COPY
cmrknutfm03e34hlexqqo3las	cmrknut0y039h4hlekczcvqvm	\N	SELL	2800000	2026-06-21 07:11:07.761	2026-07-14 13:02:05.698	cmrknuqre02kf4hlefzxppos4	COPY
cmrknutfw03e74hle9p2xwfow	cmrknut0y039h4hlekczcvqvm	\N	SELL	4480000	2026-06-21 07:12:08.462	2026-07-14 13:02:05.709	cmrknuo7p01g74hle1tay622j	ORIGINAL
cmrknutg703eb4hle5cgfnw09	cmrknut0y039h4hlekczcvqvm	\N	SELL	2450000	2026-06-21 07:12:08.462	2026-07-14 13:02:05.719	cmrknuo7p01g74hle1tay622j	HIGH_COPY
cmrknutgh03ef4hlemhowjphu	cmrknut0y039h4hlekczcvqvm	\N	SELL	1800000	2026-06-21 07:12:08.462	2026-07-14 13:02:05.729	cmrknuo7p01g74hle1tay622j	COPY
cmrknutgs03ej4hlevvcku55u	cmrknut1e039j4hleuqvcm4l6	\N	SELL	1950000	2026-06-21 07:13:45.152	2026-07-14 13:02:05.74	cmrknunwm01c74hlesrwvz511	ORIGINAL
cmrknuth203en4hlezjopmblq	cmrknut1e039j4hleuqvcm4l6	\N	SELL	1540000	2026-06-21 07:13:45.152	2026-07-14 13:02:05.75	cmrknunwm01c74hlesrwvz511	HIGH_COPY
cmrknuthd03er4hlesk010yy1	cmrknut1e039j4hleuqvcm4l6	\N	SELL	900000	2026-06-21 07:13:45.152	2026-07-14 13:02:05.761	cmrknunwm01c74hlesrwvz511	COPY
cmrknutho03ev4hle1dg20hov	cmrknut1e039j4hleuqvcm4l6	\N	SELL	1350000	2026-06-21 07:16:18.601	2026-07-14 13:02:05.772	cmrknus0l02yn4hlezo2m40jx	HIGH_COPY
cmrknuthy03ez4hlehklnz67n	cmrknut1e039j4hleuqvcm4l6	\N	SELL	500000	2026-06-21 07:16:18.601	2026-07-14 13:02:05.782	cmrknus0l02yn4hlezo2m40jx	COPY
cmrknuti903f34hleup4hhdjv	cmrkbbzjk000amneoowf62wmn	\N	SELL	2980000	2026-06-21 07:19:08.023	2026-07-14 13:02:05.793	cmrknupck02634hlegn9w2wy1	ORIGINAL
cmrknutij03f74hlef593b8cj	cmrkbbzjk000amneoowf62wmn	\N	SELL	2200000	2026-06-21 07:19:08.023	2026-07-14 13:02:05.804	cmrknupck02634hlegn9w2wy1	HIGH_COPY
cmrknutiu03fb4hlefr40obc4	cmrkbbzjk000amneoowf62wmn	\N	SELL	1600000	2026-06-21 07:19:08.023	2026-07-14 13:02:05.814	cmrknupck02634hlegn9w2wy1	COPY
cmrknutj503ff4hle6tp0h8dc	cmrknut1e039j4hleuqvcm4l6	\N	SELL	1900000	2026-06-21 07:23:54.578	2026-07-14 13:02:05.825	cmrknupdv026f4hlexbzeua3g	ORIGINAL
cmrknutjf03fj4hlex3lwbwrj	cmrknut1e039j4hleuqvcm4l6	\N	SELL	1250000	2026-06-21 07:23:54.578	2026-07-14 13:02:05.835	cmrknupdv026f4hlexbzeua3g	HIGH_COPY
cmrknutjp03fn4hleiyuaoeys	cmrknut1e039j4hleuqvcm4l6	\N	SELL	500	2026-06-21 07:23:54.578	2026-07-14 13:02:05.846	cmrknupdv026f4hlexbzeua3g	COPY
cmrknutk003fr4hlem3lii1vf	cmrkbbzjk000amneoowf62wmn	\N	SELL	4790000	2026-06-21 07:25:54.511	2026-07-14 13:02:05.856	cmrknuslp034z4hlepmsig8d8	ORIGINAL
cmrknutka03fv4hlezsdlk0ap	cmrkbbzjk000amneoowf62wmn	\N	SELL	3550000	2026-06-21 07:25:54.511	2026-07-14 13:02:05.866	cmrknuslp034z4hlepmsig8d8	HIGH_COPY
cmrknutkk03fz4hleaxec5o4t	cmrkbbzjk000amneoowf62wmn	\N	SELL	2500000	2026-06-21 07:25:54.511	2026-07-14 13:02:05.876	cmrknuslp034z4hlepmsig8d8	COPY
cmrknutkv03g34hlekcotqcwe	cmrknut0y039h4hlekczcvqvm	\N	SELL	4580000	2026-06-21 07:35:53.719	2026-07-14 13:02:05.887	cmrknuk9m00514hleychr4spm	ORIGINAL
cmrknutl503g74hlejledxbif	cmrknut0y039h4hlekczcvqvm	\N	SELL	3250000	2026-06-21 07:35:53.719	2026-07-14 13:02:05.897	cmrknuk9m00514hleychr4spm	HIGH_COPY
cmrknutlh03gb4hlefj1oqad9	cmrknut0y039h4hlekczcvqvm	\N	SELL	1800000	2026-06-21 07:35:53.719	2026-07-14 13:02:05.909	cmrknuk9m00514hleychr4spm	COPY
cmrknutlt03gf4hlemda1znjq	cmrkbbzjk000amneoowf62wmn	\N	SELL	4850000	2026-06-22 04:01:48.757	2026-07-14 13:02:05.921	cmrknusma03554hle4uw4c3e2	ORIGINAL
cmrknutm403gj4hle3hm2e020	cmrkbbzjk000amneoowf62wmn	\N	SELL	3220000	2026-06-22 04:01:48.757	2026-07-14 13:02:05.932	cmrknusma03554hle4uw4c3e2	HIGH_COPY
cmrknutmf03gn4hlearicvo1g	cmrkbbzjk000amneoowf62wmn	\N	SELL	2800000	2026-06-22 04:01:48.757	2026-07-14 13:02:05.944	cmrknusma03554hle4uw4c3e2	COPY
cmrknutmr03gr4hlemw5aqleh	cmrknut1e039j4hleuqvcm4l6	\N	SELL	1210000	2026-06-22 06:03:56.367	2026-07-14 13:02:05.955	cmrknus4402zp4hlem8rkfrdy	ORIGINAL
cmrknutn203gv4hle6d5a6kjx	cmrknut1e039j4hleuqvcm4l6	\N	SELL	890000	2026-06-22 06:03:56.367	2026-07-14 13:02:05.966	cmrknus4402zp4hlem8rkfrdy	HIGH_COPY
cmrknutnc03gz4hlevgc0h5vs	cmrknut1e039j4hleuqvcm4l6	\N	SELL	500000	2026-06-22 06:03:56.367	2026-07-14 13:02:05.977	cmrknus4402zp4hlem8rkfrdy	COPY
cmrknutno03h34hlegb02qbmi	cmrknut0y039h4hlekczcvqvm	\N	SELL	4480000	2026-06-22 06:04:30.865	2026-07-14 13:02:05.988	cmrknus4402zp4hlem8rkfrdy	ORIGINAL
cmrknutny03h74hle6pt2ptaa	cmrknut0y039h4hlekczcvqvm	\N	SELL	3250000	2026-06-22 06:04:30.865	2026-07-14 13:02:05.999	cmrknus4402zp4hlem8rkfrdy	HIGH_COPY
cmrknutoa03hb4hleo3xas42x	cmrknut0y039h4hlekczcvqvm	\N	SELL	1900000	2026-06-22 06:04:30.865	2026-07-14 13:02:06.01	cmrknus4402zp4hlem8rkfrdy	COPY
cmrknutol03hf4hlevkm2mr4r	cmrknut0y039h4hlekczcvqvm	\N	SELL	3920000	2026-06-22 06:05:23.265	2026-07-14 13:02:06.021	cmrknuorx01tj4hlebwnvqk6a	ORIGINAL
cmrknutov03hj4hleolg4khtf	cmrknut0y039h4hlekczcvqvm	\N	SELL	2580000	2026-06-22 06:05:23.265	2026-07-14 13:02:06.031	cmrknuorx01tj4hlebwnvqk6a	HIGH_COPY
cmrknutp603hn4hlen81c3hjb	cmrknut0y039h4hlekczcvqvm	\N	SELL	1800000	2026-06-22 06:05:23.265	2026-07-14 13:02:06.043	cmrknuorx01tj4hlebwnvqk6a	COPY
cmrknutph03hr4hlet3hla9to	cmrknut0y039h4hlekczcvqvm	\N	SELL	4200000	2026-06-30 13:32:09.873	2026-07-14 13:02:06.053	cmrknuljf00ot4hledyrnjask	ORIGINAL
cmrknutpr03hv4hlekv9wxo32	cmrknut0y039h4hlekczcvqvm	\N	SELL	2950000	2026-06-30 13:32:09.873	2026-07-14 13:02:06.064	cmrknuljf00ot4hledyrnjask	HIGH_COPY
cmrknutq203hz4hleqf7s0fjw	cmrknut0y039h4hlekczcvqvm	\N	SELL	1950000	2026-06-30 13:32:09.873	2026-07-14 13:02:06.074	cmrknuljf00ot4hledyrnjask	COPY
cmrknutqb03i34hledknx62mf	cmrkbbzjk000amneoowf62wmn	\N	SELL	2500000	2026-06-30 08:14:05.995	2026-07-14 13:02:06.084	cmrknumws012f4hlenzrif5fg	ORIGINAL
cmrknutqm03i74hle7mp6pxw7	cmrkbbzjk000amneoowf62wmn	\N	SELL	1800000	2026-06-30 08:14:05.995	2026-07-14 13:02:06.094	cmrknumws012f4hlenzrif5fg	HIGH_COPY
cmrknutqw03ib4hlep17ugber	cmrkbbzjk000amneoowf62wmn	\N	SELL	1300000	2026-06-30 08:14:05.995	2026-07-14 13:02:06.105	cmrknumws012f4hlenzrif5fg	COPY
cmrknutr603if4hlershlxp39	cmrkbbzjk000amneoowf62wmn	\N	SELL	2700000	2026-06-30 07:36:54.004	2026-07-14 13:02:06.115	cmrknus0l02yn4hlezo2m40jx	ORIGINAL
cmrknutrg03ij4hlejhh846yb	cmrkbbzjk000amneoowf62wmn	\N	SELL	1700000	2026-06-30 07:36:54.004	2026-07-14 13:02:06.125	cmrknus0l02yn4hlezo2m40jx	HIGH_COPY
cmrknutrr03in4hle5uemo98r	cmrkbbzjk000amneoowf62wmn	\N	SELL	1100000	2026-06-30 07:36:54.004	2026-07-14 13:02:06.135	cmrknus0l02yn4hlezo2m40jx	COPY
cmrknuts103ir4hlek1wfw3bp	cmrkbbzjk000amneoowf62wmn	\N	SELL	2100000	2026-06-30 07:37:49.115	2026-07-14 13:02:06.145	cmrknuqp902jr4hlej33uq7e6	ORIGINAL
cmrknutsb03iv4hle5bckgqv9	cmrkbbzjk000amneoowf62wmn	\N	SELL	1500000	2026-06-30 07:37:49.115	2026-07-14 13:02:06.155	cmrknuqp902jr4hlej33uq7e6	HIGH_COPY
cmrknutsl03iz4hle1pe78syv	cmrkbbzjk000amneoowf62wmn	\N	SELL	900000	2026-06-30 07:37:49.115	2026-07-14 13:02:06.166	cmrknuqp902jr4hlej33uq7e6	COPY
cmrknutsw03j34hlej07hq6on	cmrkbbzjk000amneoowf62wmn	\N	SELL	2200000	2026-06-30 07:38:43.689	2026-07-14 13:02:06.176	cmrknup6z024j4hlen4lnzqxc	ORIGINAL
cmrknutt503j74hleni5958yl	cmrkbbzjk000amneoowf62wmn	\N	SELL	1600000	2026-06-30 07:38:43.689	2026-07-14 13:02:06.186	cmrknup6z024j4hlen4lnzqxc	HIGH_COPY
cmrknuttf03jb4hlee5rdod06	cmrkbbzjk000amneoowf62wmn	\N	SELL	1000000	2026-06-30 07:38:43.689	2026-07-14 13:02:06.196	cmrknup6z024j4hlen4lnzqxc	COPY
cmrknuttq03jf4hle8fm4dnwt	cmrkbbzjk000amneoowf62wmn	\N	SELL	1400000	2026-06-30 07:40:02.184	2026-07-14 13:02:06.206	cmrknusdx032p4hled5k27zvu	ORIGINAL
cmrknutu003jj4hleuuob3icn	cmrkbbzjk000amneoowf62wmn	\N	SELL	900000	2026-06-30 07:40:02.184	2026-07-14 13:02:06.217	cmrknusdx032p4hled5k27zvu	HIGH_COPY
cmrknutua03jn4hle3tzrb156	cmrkbbzjk000amneoowf62wmn	\N	SELL	500000	2026-06-30 07:40:02.184	2026-07-14 13:02:06.227	cmrknusdx032p4hled5k27zvu	COPY
cmrknutul03jr4hlerlecgbss	cmrkbbzjk000amneoowf62wmn	\N	SELL	2200000	2026-06-30 07:45:47.213	2026-07-14 13:02:06.237	cmrknurdz02qx4hle78n4g5hg	ORIGINAL
cmrknutuu03jv4hlejcojjb5o	cmrkbbzjk000amneoowf62wmn	\N	SELL	1600000	2026-06-30 07:45:47.213	2026-07-14 13:02:06.247	cmrknurdz02qx4hle78n4g5hg	HIGH_COPY
cmrknutv603jz4hlew1va68jj	cmrkbbzjk000amneoowf62wmn	\N	SELL	1000000	2026-06-30 07:45:47.213	2026-07-14 13:02:06.259	cmrknurdz02qx4hle78n4g5hg	COPY
cmrknutvi03k34hlexp1ej8n2	cmrkbbzjk000amneoowf62wmn	\N	SELL	2600000	2026-06-30 07:52:30.843	2026-07-14 13:02:06.27	cmrknuk45002b4hle2tooy7xy	ORIGINAL
cmrknutvt03k74hlerv7de4sg	cmrkbbzjk000amneoowf62wmn	\N	SELL	1700000	2026-06-30 07:52:30.843	2026-07-14 13:02:06.281	cmrknuk45002b4hle2tooy7xy	HIGH_COPY
cmrknutw503kb4hlekukju2en	cmrkbbzjk000amneoowf62wmn	\N	SELL	900000	2026-06-30 07:52:30.843	2026-07-14 13:02:06.293	cmrknuk45002b4hle2tooy7xy	COPY
cmrknutwg03kf4hle3zyf5nqt	cmrkbbzjk000amneoowf62wmn	\N	SELL	3800000	2026-06-30 07:59:08.14	2026-07-14 13:02:06.304	cmrknukj1009x4hle6uioxq9r	ORIGINAL
cmrknutwr03kj4hle2yiaoivl	cmrkbbzjk000amneoowf62wmn	\N	SELL	2800000	2026-06-30 07:59:08.14	2026-07-14 13:02:06.315	cmrknukj1009x4hle6uioxq9r	HIGH_COPY
cmrknutx203kn4hle4qod21g0	cmrkbbzjk000amneoowf62wmn	\N	SELL	1800000	2026-06-30 07:59:08.14	2026-07-14 13:02:06.327	cmrknukj1009x4hle6uioxq9r	COPY
cmrknutxe03kr4hleyxpvgmu2	cmrkbbzjk000amneoowf62wmn	\N	SELL	4300000	2026-06-30 07:59:45.704	2026-07-14 13:02:06.339	cmrknumyz01334hleloqz20ui	ORIGINAL
cmrknutxp03kv4hleuvs1pdxq	cmrkbbzjk000amneoowf62wmn	\N	SELL	3200000	2026-06-30 07:59:45.704	2026-07-14 13:02:06.35	cmrknumyz01334hleloqz20ui	HIGH_COPY
cmrknuty103kz4hlejtlhg1gz	cmrkbbzjk000amneoowf62wmn	\N	SELL	2500000	2026-06-30 07:59:45.704	2026-07-14 13:02:06.361	cmrknumyz01334hleloqz20ui	COPY
cmrknutyc03l34hleh1vt22ul	cmrkbbzjk000amneoowf62wmn	\N	SELL	5900000	2026-06-30 08:02:02.587	2026-07-14 13:02:06.372	cmrknukid009d4hlejp5ntjfo	ORIGINAL
cmrknutym03l74hlebzzc1hwg	cmrkbbzjk000amneoowf62wmn	\N	SELL	4700000	2026-06-30 08:02:02.587	2026-07-14 13:02:06.383	cmrknukid009d4hlejp5ntjfo	HIGH_COPY
cmrknutyx03lb4hlewvrr1b6q	cmrkbbzjk000amneoowf62wmn	\N	SELL	3500000	2026-06-30 08:02:02.587	2026-07-14 13:02:06.393	cmrknukid009d4hlejp5ntjfo	COPY
cmrknutz803lf4hleg2h1asdr	cmrkbbzjk000amneoowf62wmn	\N	SELL	2500000	2026-06-30 08:04:23.383	2026-07-14 13:02:06.404	cmrknukao005f4hle9fi9lqkd	ORIGINAL
cmrknutzj03lj4hlerzuwf2p3	cmrkbbzjk000amneoowf62wmn	\N	SELL	1700000	2026-06-30 08:04:23.383	2026-07-14 13:02:06.415	cmrknukao005f4hle9fi9lqkd	HIGH_COPY
cmrknutzu03ln4hlebul7nnro	cmrkbbzjk000amneoowf62wmn	\N	SELL	1300000	2026-06-30 08:04:23.383	2026-07-14 13:02:06.426	cmrknukao005f4hle9fi9lqkd	COPY
cmrknuu0503lr4hle2u5j510r	cmrkbbzjk000amneoowf62wmn	\N	SELL	3500000	2026-06-30 08:05:23.885	2026-07-14 13:02:06.437	cmrknuk3m00214hleqygbqv6j	ORIGINAL
cmrknuu0h03lv4hleumt00h4k	cmrkbbzjk000amneoowf62wmn	\N	SELL	2600000	2026-06-30 08:05:23.885	2026-07-14 13:02:06.449	cmrknuk3m00214hleqygbqv6j	HIGH_COPY
cmrknuu0s03lz4hleq1cnz50k	cmrkbbzjk000amneoowf62wmn	\N	SELL	1600000	2026-06-30 08:05:23.885	2026-07-14 13:02:06.46	cmrknuk3m00214hleqygbqv6j	COPY
cmrknuu1303m34hle28tnaxlt	cmrkbbzjk000amneoowf62wmn	\N	SELL	4500000	2026-06-30 08:06:15.122	2026-07-14 13:02:06.471	cmrknuk9x00554hle9um1cc7q	ORIGINAL
cmrknuu1e03m74hlewjns1p0y	cmrkbbzjk000amneoowf62wmn	\N	SELL	3700000	2026-06-30 08:06:15.122	2026-07-14 13:02:06.482	cmrknuk9x00554hle9um1cc7q	HIGH_COPY
cmrknuu1o03mb4hlexbge55q5	cmrkbbzjk000amneoowf62wmn	\N	SELL	2600000	2026-06-30 08:06:15.122	2026-07-14 13:02:06.492	cmrknuk9x00554hle9um1cc7q	COPY
cmrknuu2003mf4hlef4i21ogf	cmrkbbzjk000amneoowf62wmn	\N	SELL	1900000	2026-06-30 08:06:58.271	2026-07-14 13:02:06.504	cmrknuk68003b4hleloxciixq	ORIGINAL
cmrknuu2b03mj4hle2xclzrmz	cmrkbbzjk000amneoowf62wmn	\N	SELL	1400000	2026-06-30 08:06:58.271	2026-07-14 13:02:06.515	cmrknuk68003b4hleloxciixq	HIGH_COPY
cmrknuu2l03mn4hleozye6bx7	cmrkbbzjk000amneoowf62wmn	\N	SELL	1000000	2026-06-30 08:06:58.271	2026-07-14 13:02:06.526	cmrknuk68003b4hleloxciixq	COPY
cmrknuu2x03mr4hle157az45l	cmrkbbzjk000amneoowf62wmn	\N	SELL	1900000	2026-06-30 08:08:32.763	2026-07-14 13:02:06.538	cmrknurr502vx4hle7a5jpm1p	ORIGINAL
cmrknuu3903mv4hleja78enbw	cmrkbbzjk000amneoowf62wmn	\N	SELL	1400000	2026-06-30 08:08:32.763	2026-07-14 13:02:06.549	cmrknurr502vx4hle7a5jpm1p	HIGH_COPY
cmrknuu3j03mz4hlef1rjig2n	cmrkbbzjk000amneoowf62wmn	\N	SELL	1000000	2026-06-30 08:08:32.763	2026-07-14 13:02:06.56	cmrknurr502vx4hle7a5jpm1p	COPY
cmrknuu3v03n34hle1r9vmkqu	cmrkbbzjk000amneoowf62wmn	\N	SELL	2100000	2026-06-30 08:09:06.095	2026-07-14 13:02:06.571	cmrknuk50002n4hlevq2b3czx	ORIGINAL
cmrknuu4603n74hlezh2nuktx	cmrkbbzjk000amneoowf62wmn	\N	SELL	1600000	2026-06-30 08:09:06.095	2026-07-14 13:02:06.582	cmrknuk50002n4hlevq2b3czx	HIGH_COPY
cmrknuu4g03nb4hleuzdyfggf	cmrkbbzjk000amneoowf62wmn	\N	SELL	1100000	2026-06-30 08:09:06.095	2026-07-14 13:02:06.593	cmrknuk50002n4hlevq2b3czx	COPY
cmrknuu4s03nf4hle8g1prtej	cmrkbbzjk000amneoowf62wmn	\N	SELL	2500000	2026-06-30 08:09:40.185	2026-07-14 13:02:06.604	cmrknuk7e003x4hleakqib6r2	ORIGINAL
cmrknuu5303nj4hlep78v7d6s	cmrkbbzjk000amneoowf62wmn	\N	SELL	1800000	2026-06-30 08:09:40.185	2026-07-14 13:02:06.615	cmrknuk7e003x4hleakqib6r2	HIGH_COPY
cmrknuu5e03nn4hleuu27dkmc	cmrkbbzjk000amneoowf62wmn	\N	SELL	1300000	2026-06-30 08:09:40.185	2026-07-14 13:02:06.626	cmrknuk7e003x4hleakqib6r2	COPY
cmrknuu5p03nr4hleiuny1edm	cmrkbbzjk000amneoowf62wmn	\N	SELL	2500000	2026-06-30 08:10:14.729	2026-07-14 13:02:06.637	cmrknukf5006z4hleqkmh6fuc	ORIGINAL
cmrknuu6003nv4hlezl0l222q	cmrkbbzjk000amneoowf62wmn	\N	SELL	1800000	2026-06-30 08:10:14.729	2026-07-14 13:02:06.648	cmrknukf5006z4hleqkmh6fuc	HIGH_COPY
cmrknuu6b03nz4hlefklazkmk	cmrkbbzjk000amneoowf62wmn	\N	SELL	1200000	2026-06-30 08:10:14.729	2026-07-14 13:02:06.66	cmrknukf5006z4hleqkmh6fuc	COPY
cmrknuu6n03o34hledn9qox8t	cmrkbbzjk000amneoowf62wmn	\N	SELL	2700000	2026-06-30 08:11:43.627	2026-07-14 13:02:06.671	cmrknuonx01qp4hlezieomuv6	ORIGINAL
cmrknuu6w03o74hleanoj7ziv	cmrkbbzjk000amneoowf62wmn	\N	SELL	1900000	2026-06-30 08:11:43.627	2026-07-14 13:02:06.681	cmrknuonx01qp4hlezieomuv6	HIGH_COPY
cmrknuu7703ob4hlefnnssw0p	cmrkbbzjk000amneoowf62wmn	\N	SELL	1400000	2026-06-30 08:11:43.627	2026-07-14 13:02:06.691	cmrknuonx01qp4hlezieomuv6	COPY
cmrknuu7h03of4hle2um389mm	cmrkbbzjk000amneoowf62wmn	\N	SELL	2300000	2026-06-30 08:12:09.699	2026-07-14 13:02:06.702	cmrknuki300934hle8ixf92ig	ORIGINAL
cmrknuu7s03oj4hlegjlk8upb	cmrkbbzjk000amneoowf62wmn	\N	SELL	1700000	2026-06-30 08:12:09.699	2026-07-14 13:02:06.712	cmrknuki300934hle8ixf92ig	HIGH_COPY
cmrknuu8303on4hle6116n37t	cmrkbbzjk000amneoowf62wmn	\N	SELL	1200000	2026-06-30 08:12:09.699	2026-07-14 13:02:06.723	cmrknuki300934hle8ixf92ig	COPY
cmrknuu8d03or4hle1etfbqkg	cmrkbbzjk000amneoowf62wmn	\N	SELL	2750000	2026-06-30 08:15:37.156	2026-07-14 13:02:06.733	cmrknuo7k01g54hleyba4r0x1	ORIGINAL
cmrknuu8n03ov4hle8fyqh8vk	cmrkbbzjk000amneoowf62wmn	\N	SELL	1900000	2026-06-30 08:15:37.156	2026-07-14 13:02:06.743	cmrknuo7k01g54hleyba4r0x1	HIGH_COPY
cmrknuu8y03oz4hle7ep8denj	cmrkbbzjk000amneoowf62wmn	\N	SELL	3200000	2026-06-30 08:16:40.028	2026-07-14 13:02:06.755	cmrknuool01r74hle77xz53b6	ORIGINAL
cmrknuu9903p34hleludnbjep	cmrkbbzjk000amneoowf62wmn	\N	SELL	2100000	2026-06-30 08:16:40.028	2026-07-14 13:02:06.766	cmrknuool01r74hle77xz53b6	HIGH_COPY
cmrknuu9k03p74hle5weui3pr	cmrkbbzjk000amneoowf62wmn	\N	SELL	1300000	2026-06-30 08:16:40.028	2026-07-14 13:02:06.776	cmrknuool01r74hle77xz53b6	COPY
cmrknuu9v03pb4hleihxtwmhy	cmrkbbzjk000amneoowf62wmn	\N	SELL	1800000	2026-06-30 08:17:38.965	2026-07-14 13:02:06.787	cmrknukcj00634hlez8h4mhht	ORIGINAL
cmrknuua503pf4hlebj68w3ny	cmrkbbzjk000amneoowf62wmn	\N	SELL	1200000	2026-06-30 08:17:38.965	2026-07-14 13:02:06.797	cmrknukcj00634hlez8h4mhht	HIGH_COPY
cmrknuuag03pj4hlel09gky63	cmrkbbzjk000amneoowf62wmn	\N	SELL	700000	2026-06-30 08:17:38.965	2026-07-14 13:02:06.809	cmrknukcj00634hlez8h4mhht	COPY
cmrknuuas03pn4hle11b7h54y	cmrknut0y039h4hlekczcvqvm	\N	SELL	15950000	2026-06-30 09:23:30.947	2026-07-14 13:02:06.82	cmrknuki300934hle8ixf92ig	ORIGINAL
cmrknuub203pr4hle8hpfd3o2	cmrknut0y039h4hlekczcvqvm	\N	SELL	13380000	2026-06-30 09:23:30.947	2026-07-14 13:02:06.83	cmrknuki300934hle8ixf92ig	HIGH_COPY
cmrknuubc03pv4hleod8n5t4p	cmrknut0y039h4hlekczcvqvm	\N	SELL	3950000	2026-06-30 09:23:30.947	2026-07-14 13:02:06.841	cmrknuki300934hle8ixf92ig	COPY
cmrknuubn03pz4hlese3mpu7p	cmrknut0y039h4hlekczcvqvm	\N	SELL	19480000	2026-06-30 09:25:04.426	2026-07-14 13:02:06.851	cmrknupdv026f4hlexbzeua3g	ORIGINAL
cmrknuuby03q34hleofgt0ml7	cmrknut0y039h4hlekczcvqvm	\N	SELL	15500000	2026-06-30 09:25:04.426	2026-07-14 13:02:06.862	cmrknupdv026f4hlexbzeua3g	HIGH_COPY
cmrknuuca03q74hleo35hv9fl	cmrknut0y039h4hlekczcvqvm	\N	SELL	2700000	2026-06-30 09:25:04.426	2026-07-14 13:02:06.874	cmrknupdv026f4hlexbzeua3g	COPY
cmrknuuck03qb4hleit7865d0	cmrknut0y039h4hlekczcvqvm	\N	SELL	12240000	2026-06-30 09:28:10.725	2026-07-14 13:02:06.884	cmrknum3k00u34hlelwoa12ez	ORIGINAL
cmrknuucv03qf4hle9gvtwm7a	cmrknut0y039h4hlekczcvqvm	\N	SELL	9540000	2026-06-30 09:28:10.725	2026-07-14 13:02:06.895	cmrknum3k00u34hlelwoa12ez	HIGH_COPY
cmrknuud603qj4hle9ohf5yfc	cmrknut0y039h4hlekczcvqvm	\N	SELL	3900000	2026-06-30 09:28:10.725	2026-07-14 13:02:06.907	cmrknum3k00u34hlelwoa12ez	COPY
cmrknuudh03qn4hle55k8qitj	cmrknut0y039h4hlekczcvqvm	\N	SELL	9820000	2026-06-30 10:22:32.124	2026-07-14 13:02:06.917	cmrknunwf01c54hlel5xsbnv5	ORIGINAL
cmrknuudt03qr4hle8wj9hpu7	cmrknut0y039h4hlekczcvqvm	\N	SELL	6400000	2026-06-30 10:22:32.124	2026-07-14 13:02:06.929	cmrknunwf01c54hlel5xsbnv5	HIGH_COPY
cmrknuue503qv4hleizanbg3q	cmrknut0y039h4hlekczcvqvm	\N	SELL	3300000	2026-06-30 10:22:32.124	2026-07-14 13:02:06.941	cmrknunwf01c54hlel5xsbnv5	COPY
cmrknuueg03qz4hlebxka6xoe	cmrknut0y039h4hlekczcvqvm	\N	SELL	25900000	2026-06-30 13:00:40.062	2026-07-14 13:02:06.952	cmrknurk502tv4hledarwecyu	ORIGINAL
cmrknuuer03r34hleixtoblz4	cmrknut0y039h4hlekczcvqvm	\N	SELL	23400000	2026-06-30 13:00:40.062	2026-07-14 13:02:06.963	cmrknurk502tv4hledarwecyu	HIGH_COPY
cmrknuuf103r74hlebblpoxks	cmrknut0y039h4hlekczcvqvm	\N	SELL	16100000	2026-06-30 13:00:40.062	2026-07-14 13:02:06.973	cmrknurk502tv4hledarwecyu	COPY
cmrknuufb03rb4hle0m45wxz1	cmrknut0y039h4hlekczcvqvm	\N	SELL	4550000	2026-06-30 13:41:59.776	2026-07-14 13:02:06.984	cmrknus9i031d4hleoktyupw4	ORIGINAL
cmrknuufm03rf4hlewl1fwsau	cmrknut0y039h4hlekczcvqvm	\N	SELL	3250000	2026-06-30 13:41:59.776	2026-07-14 13:02:06.995	cmrknus9i031d4hleoktyupw4	HIGH_COPY
cmrknuufx03rj4hle0nsbcdcg	cmrknut0y039h4hlekczcvqvm	\N	SELL	1800000	2026-06-30 13:41:59.776	2026-07-14 13:02:07.006	cmrknus9i031d4hleoktyupw4	COPY
cmrknuug803rn4hle2gn7yf7q	cmrknut0y039h4hlekczcvqvm	\N	SELL	12950000	2026-06-30 13:50:16.77	2026-07-14 13:02:07.016	cmrknunwm01c74hlesrwvz511	ORIGINAL
cmrknuugi03rr4hle1v2u79d3	cmrknut0y039h4hlekczcvqvm	\N	SELL	10800000	2026-06-30 13:50:16.77	2026-07-14 13:02:07.026	cmrknunwm01c74hlesrwvz511	HIGH_COPY
cmrknuugt03rv4hleu6jsnjf3	cmrknut0y039h4hlekczcvqvm	\N	SELL	3500000	2026-06-30 13:50:16.77	2026-07-14 13:02:07.037	cmrknunwm01c74hlesrwvz511	COPY
cmrknuuh303rz4hledqiafxdp	cmrkbbzjk000amneoowf62wmn	\N	SELL	1400000	2026-06-30 08:19:31.152	2026-07-14 13:02:07.048	cmrknumlc00yj4hlecifwdi7b	ORIGINAL
cmrknuuhd03s34hlercgi4k10	cmrkbbzjk000amneoowf62wmn	\N	SELL	900000	2026-06-30 08:19:31.152	2026-07-14 13:02:07.058	cmrknumlc00yj4hlecifwdi7b	HIGH_COPY
cmrknuuho03s74hleb6a0rrtm	cmrkbbzjk000amneoowf62wmn	\N	SELL	500000	2026-06-30 08:19:31.152	2026-07-14 13:02:07.068	cmrknumlc00yj4hlecifwdi7b	COPY
cmrknuuhy03sb4hleo57yxdoz	cmrkbbzjk000amneoowf62wmn	\N	SELL	2900000	2026-06-30 08:21:07.831	2026-07-14 13:02:07.078	cmrknuro602v34hleg39gtijg	ORIGINAL
cmrknuui903sf4hle8x0k99k0	cmrkbbzjk000amneoowf62wmn	\N	SELL	1900000	2026-06-30 08:21:07.831	2026-07-14 13:02:07.089	cmrknuro602v34hleg39gtijg	HIGH_COPY
cmrknuuij03sj4hleoxi0vyxz	cmrkbbzjk000amneoowf62wmn	\N	SELL	1200000	2026-06-30 08:21:07.831	2026-07-14 13:02:07.099	cmrknuro602v34hleg39gtijg	COPY
cmrknuuiu03sn4hle7oor1t43	cmrkbbzjk000amneoowf62wmn	\N	SELL	2400000	2026-06-30 08:22:48.444	2026-07-14 13:02:07.111	cmrknus80030v4hleepdobkl8	ORIGINAL
cmrknuuj603sr4hle1c6x8e6f	cmrkbbzjk000amneoowf62wmn	\N	SELL	1700000	2026-06-30 08:22:48.444	2026-07-14 13:02:07.123	cmrknus80030v4hleepdobkl8	HIGH_COPY
cmrknuujg03sv4hlenl6bf6zo	cmrkbbzjk000amneoowf62wmn	\N	SELL	1100000	2026-06-30 08:22:48.444	2026-07-14 13:02:07.132	cmrknus80030v4hleepdobkl8	COPY
cmrknuujr03sz4hlexqewhdsk	cmrkbbzjk000amneoowf62wmn	\N	SELL	4700000	2026-06-30 08:23:22.716	2026-07-14 13:02:07.143	cmrknunwf01c54hlel5xsbnv5	ORIGINAL
cmrknuuk103t34hlei28fnldv	cmrkbbzjk000amneoowf62wmn	\N	SELL	3800000	2026-06-30 08:23:22.716	2026-07-14 13:02:07.154	cmrknunwf01c54hlel5xsbnv5	HIGH_COPY
cmrknuukd03t74hlebv8neem4	cmrkbbzjk000amneoowf62wmn	\N	SELL	3100000	2026-06-30 08:23:22.716	2026-07-14 13:02:07.165	cmrknunwf01c54hlel5xsbnv5	COPY
cmrknuukp03tb4hlei93mbii2	cmrkbbzjk000amneoowf62wmn	\N	SELL	2800000	2026-06-30 08:23:49.006	2026-07-14 13:02:07.177	cmrknusga033f4hlelpb105q2	ORIGINAL
cmrknuul003tf4hlej1bej6o0	cmrkbbzjk000amneoowf62wmn	\N	SELL	1800000	2026-06-30 08:23:49.006	2026-07-14 13:02:07.188	cmrknusga033f4hlelpb105q2	HIGH_COPY
cmrknuul903tj4hle0rxgybyy	cmrkbbzjk000amneoowf62wmn	\N	SELL	1200000	2026-06-30 08:23:49.006	2026-07-14 13:02:07.197	cmrknusga033f4hlelpb105q2	COPY
cmrknuulk03tn4hle9qqnk8bo	cmrkbbzjk000amneoowf62wmn	\N	SELL	3050000	2026-06-30 08:24:31.254	2026-07-14 13:02:07.208	cmrknul6c00h14hleeh8ukjgn	ORIGINAL
cmrknuulv03tr4hleeg5yisip	cmrkbbzjk000amneoowf62wmn	\N	SELL	1900000	2026-06-30 08:24:31.254	2026-07-14 13:02:07.219	cmrknul6c00h14hleeh8ukjgn	HIGH_COPY
cmrknuum503tv4hle3op91zpp	cmrkbbzjk000amneoowf62wmn	\N	SELL	1200000	2026-06-30 08:24:31.254	2026-07-14 13:02:07.229	cmrknul6c00h14hleeh8ukjgn	COPY
cmrknuumg03tz4hle0lz5ze16	cmrkbbzjk000amneoowf62wmn	\N	SELL	4300000	2026-06-30 08:24:58.607	2026-07-14 13:02:07.24	cmrknurk502tv4hledarwecyu	ORIGINAL
cmrknuumr03u34hlemkto03dj	cmrkbbzjk000amneoowf62wmn	\N	SELL	3200000	2026-06-30 08:24:58.607	2026-07-14 13:02:07.251	cmrknurk502tv4hledarwecyu	HIGH_COPY
cmrknuun303u74hlecn8t8zxw	cmrkbbzjk000amneoowf62wmn	\N	SELL	2300000	2026-06-30 08:24:58.607	2026-07-14 13:02:07.263	cmrknurk502tv4hledarwecyu	COPY
cmrknuune03ub4hle97i4681v	cmrkbbzjk000amneoowf62wmn	\N	SELL	1900000	2026-06-30 08:27:24.551	2026-07-14 13:02:07.274	cmrknusa7031l4hlese5bukdo	ORIGINAL
cmrknuunq03uf4hleq8se1u5r	cmrkbbzjk000amneoowf62wmn	\N	SELL	1400000	2026-06-30 08:27:24.551	2026-07-14 13:02:07.286	cmrknusa7031l4hlese5bukdo	HIGH_COPY
cmrknuuo203uj4hle7bask72m	cmrkbbzjk000amneoowf62wmn	\N	SELL	900000	2026-06-30 08:27:24.551	2026-07-14 13:02:07.298	cmrknusa7031l4hlese5bukdo	COPY
cmrknuuod03un4hle6927gy0q	cmrkbbzjk000amneoowf62wmn	\N	SELL	2700000	2026-06-30 08:27:59.169	2026-07-14 13:02:07.31	cmrknung7017n4hleej9wufua	ORIGINAL
cmrknuuop03ur4hlet9evco5g	cmrkbbzjk000amneoowf62wmn	\N	SELL	1900000	2026-06-30 08:27:59.169	2026-07-14 13:02:07.321	cmrknung7017n4hleej9wufua	HIGH_COPY
cmrknuup003uv4hle8vt94wk3	cmrkbbzjk000amneoowf62wmn	\N	SELL	1200000	2026-06-30 08:27:59.169	2026-07-14 13:02:07.332	cmrknung7017n4hleej9wufua	COPY
cmrknuupa03uz4hle5wvr8jz4	cmrkbbzjk000amneoowf62wmn	\N	SELL	1900000	2026-06-30 08:29:11.646	2026-07-14 13:02:07.343	cmrknul1x00f34hle0z06dmm6	ORIGINAL
cmrknuupm03v34hlepvyx07ie	cmrkbbzjk000amneoowf62wmn	\N	SELL	1900000	2026-06-30 08:30:43.725	2026-07-14 13:02:07.354	cmrknushc033p4hleezt3rmt8	ORIGINAL
cmrknuupx03v74hle6ez4oh0t	cmrkbbzjk000amneoowf62wmn	\N	SELL	1500000	2026-06-30 08:30:43.725	2026-07-14 13:02:07.365	cmrknushc033p4hleezt3rmt8	HIGH_COPY
cmrknuuq803vb4hlelvk549rc	cmrkbbzjk000amneoowf62wmn	\N	SELL	1100000	2026-06-30 08:30:43.725	2026-07-14 13:02:07.376	cmrknushc033p4hleezt3rmt8	COPY
cmrknuuqj03vf4hlenmr2n9rl	cmrkbbzjk000amneoowf62wmn	\N	SELL	4300000	2026-06-30 08:31:20.08	2026-07-14 13:02:07.387	cmrknun1j013r4hlelevvslwu	ORIGINAL
cmrknuuqu03vj4hlee3s49bs0	cmrkbbzjk000amneoowf62wmn	\N	SELL	3100000	2026-06-30 08:31:20.08	2026-07-14 13:02:07.398	cmrknun1j013r4hlelevvslwu	HIGH_COPY
cmrknuur403vn4hle8prqlkvb	cmrkbbzjk000amneoowf62wmn	\N	SELL	1400000	2026-06-30 08:31:20.08	2026-07-14 13:02:07.409	cmrknun1j013r4hlelevvslwu	COPY
cmrknuurg03vr4hle75r51bmm	cmrkbbzjk000amneoowf62wmn	\N	SELL	2300000	2026-06-30 08:32:11.914	2026-07-14 13:02:07.42	cmrknusez03314hle881gf5vr	ORIGINAL
cmrknuurr03vv4hlehypqvsgx	cmrkbbzjk000amneoowf62wmn	\N	SELL	1700000	2026-06-30 08:32:11.914	2026-07-14 13:02:07.431	cmrknusez03314hle881gf5vr	HIGH_COPY
cmrknuus203vz4hlehliftisz	cmrkbbzjk000amneoowf62wmn	\N	SELL	1200000	2026-06-30 08:32:11.914	2026-07-14 13:02:07.442	cmrknusez03314hle881gf5vr	COPY
cmrknuuse03w34hlel0c1rvly	cmrkbbzjk000amneoowf62wmn	\N	SELL	2300000	2026-06-30 08:32:50.205	2026-07-14 13:02:07.454	cmrknus9i031d4hleoktyupw4	ORIGINAL
cmrknuusp03w74hlerrevebr0	cmrkbbzjk000amneoowf62wmn	\N	SELL	1700000	2026-06-30 08:32:50.205	2026-07-14 13:02:07.465	cmrknus9i031d4hleoktyupw4	HIGH_COPY
cmrknuut003wb4hleg12ddko9	cmrkbbzjk000amneoowf62wmn	\N	SELL	1200000	2026-06-30 08:32:50.205	2026-07-14 13:02:07.476	cmrknus9i031d4hleoktyupw4	COPY
cmrknuutb03wf4hlee7cefez7	cmrkbbzjk000amneoowf62wmn	\N	SELL	2450000	2026-06-30 08:33:24.725	2026-07-14 13:02:07.487	cmrknusc203254hlew2spvu26	ORIGINAL
cmrknuutm03wj4hlemq41z43k	cmrkbbzjk000amneoowf62wmn	\N	SELL	1800000	2026-06-30 08:33:24.725	2026-07-14 13:02:07.498	cmrknusc203254hlew2spvu26	HIGH_COPY
cmrknuutx03wn4hlevtfztlwr	cmrkbbzjk000amneoowf62wmn	\N	SELL	1200000	2026-06-30 08:33:24.725	2026-07-14 13:02:07.509	cmrknusc203254hlew2spvu26	COPY
cmrknuuu803wr4hlehyny0qum	cmrkbbzjk000amneoowf62wmn	\N	SELL	2400000	2026-06-30 08:33:59.639	2026-07-14 13:02:07.52	cmrknus8i03114hletjrabgwq	ORIGINAL
cmrknuuuj03wv4hle8ov3e8oa	cmrkbbzjk000amneoowf62wmn	\N	SELL	1800000	2026-06-30 08:33:59.639	2026-07-14 13:02:07.531	cmrknus8i03114hletjrabgwq	HIGH_COPY
cmrknuuut03wz4hle7rwlrf9i	cmrkbbzjk000amneoowf62wmn	\N	SELL	1200000	2026-06-30 08:33:59.639	2026-07-14 13:02:07.542	cmrknus8i03114hletjrabgwq	COPY
cmrknuuv503x34hle4yhgzdz4	cmrkbbzjk000amneoowf62wmn	\N	SELL	2450000	2026-06-30 08:34:37.769	2026-07-14 13:02:07.554	cmrknuriw02t34hlegycrtg44	ORIGINAL
cmrknuuvh03x74hlemt0cn133	cmrkbbzjk000amneoowf62wmn	\N	SELL	1800000	2026-06-30 08:34:37.769	2026-07-14 13:02:07.565	cmrknuriw02t34hlegycrtg44	HIGH_COPY
cmrknuuvr03xb4hle9sa05ezm	cmrkbbzjk000amneoowf62wmn	\N	SELL	1200000	2026-06-30 08:34:37.769	2026-07-14 13:02:07.576	cmrknuriw02t34hlegycrtg44	COPY
cmrknuuw303xf4hlehcp9hi9j	cmrkbbzjk000amneoowf62wmn	\N	SELL	3800000	2026-06-30 08:35:07.713	2026-07-14 13:02:07.587	cmrknuqre02kf4hlefzxppos4	ORIGINAL
cmrknuuwe03xj4hlethmgz4y8	cmrkbbzjk000amneoowf62wmn	\N	SELL	2900000	2026-06-30 08:35:07.713	2026-07-14 13:02:07.598	cmrknuqre02kf4hlefzxppos4	HIGH_COPY
cmrknuuwp03xn4hlelmtta5jh	cmrkbbzjk000amneoowf62wmn	\N	SELL	2200000	2026-06-30 08:35:07.713	2026-07-14 13:02:07.609	cmrknuqre02kf4hlefzxppos4	COPY
cmrknuux103xr4hlepjb8rzj3	cmrkbbzjk000amneoowf62wmn	\N	SELL	2800000	2026-06-30 08:35:56.028	2026-07-14 13:02:07.621	cmrknuqa802fb4hlecn2zu5rr	ORIGINAL
cmrknuuxb03xv4hleh7vwb08i	cmrkbbzjk000amneoowf62wmn	\N	SELL	1900000	2026-06-30 08:35:56.028	2026-07-14 13:02:07.632	cmrknuqa802fb4hlecn2zu5rr	HIGH_COPY
cmrknuuxm03xz4hlel4m5xkl3	cmrkbbzjk000amneoowf62wmn	\N	SELL	1300000	2026-06-30 08:35:56.028	2026-07-14 13:02:07.643	cmrknuqa802fb4hlecn2zu5rr	COPY
cmrknuuxy03y34hleqrbdys5k	cmrkbbzjk000amneoowf62wmn	\N	SELL	3850000	2026-06-30 08:36:26.248	2026-07-14 13:02:07.654	cmrknunwm01c74hlesrwvz511	ORIGINAL
cmrknuuy903y74hlewbfxhr9a	cmrkbbzjk000amneoowf62wmn	\N	SELL	2900000	2026-06-30 08:36:26.248	2026-07-14 13:02:07.665	cmrknunwm01c74hlesrwvz511	HIGH_COPY
cmrknuuyj03yb4hle21etoyse	cmrkbbzjk000amneoowf62wmn	\N	SELL	2300000	2026-06-30 08:36:26.248	2026-07-14 13:02:07.675	cmrknunwm01c74hlesrwvz511	COPY
cmrknuuyt03yf4hletre6a33s	cmrkbbzjk000amneoowf62wmn	\N	SELL	2500000	2026-06-30 08:36:52.116	2026-07-14 13:02:07.685	cmrknus3x02zn4hle9485qdhb	ORIGINAL
cmrknuuz403yj4hlezk8wnuv7	cmrkbbzjk000amneoowf62wmn	\N	SELL	1850000	2026-06-30 08:36:52.116	2026-07-14 13:02:07.696	cmrknus3x02zn4hle9485qdhb	HIGH_COPY
cmrknuuze03yn4hlen5f95761	cmrkbbzjk000amneoowf62wmn	\N	SELL	1200000	2026-06-30 08:36:52.116	2026-07-14 13:02:07.707	cmrknus3x02zn4hle9485qdhb	COPY
cmrknuuzp03yr4hlemhdc3rrk	cmrkbbzjk000amneoowf62wmn	\N	SELL	2500000	2026-06-30 08:37:22.705	2026-07-14 13:02:07.717	cmrknurqk02vr4hler7beqkzr	ORIGINAL
cmrknuuzz03yv4hleie17pvax	cmrkbbzjk000amneoowf62wmn	\N	SELL	1900000	2026-06-30 08:37:22.705	2026-07-14 13:02:07.727	cmrknurqk02vr4hler7beqkzr	HIGH_COPY
cmrknuv0a03yz4hletrrf71s5	cmrkbbzjk000amneoowf62wmn	\N	SELL	1200000	2026-06-30 08:37:22.705	2026-07-14 13:02:07.738	cmrknurqk02vr4hler7beqkzr	COPY
cmrknuv0l03z34hlebbslcwp9	cmrkbbzjk000amneoowf62wmn	\N	SELL	2500000	2026-06-30 08:37:52.142	2026-07-14 13:02:07.749	cmrknus1o02yz4hled2vvh1gd	ORIGINAL
cmrknuv0v03z74hlegiljzesw	cmrkbbzjk000amneoowf62wmn	\N	SELL	1900000	2026-06-30 08:37:52.142	2026-07-14 13:02:07.759	cmrknus1o02yz4hled2vvh1gd	HIGH_COPY
cmrknuv1603zb4hle7xdb116e	cmrkbbzjk000amneoowf62wmn	\N	SELL	1200000	2026-06-30 08:37:52.142	2026-07-14 13:02:07.77	cmrknus1o02yz4hled2vvh1gd	COPY
cmrknuv1g03zf4hlebk8ljf3w	cmrkbbzjk000amneoowf62wmn	\N	SELL	2500000	2026-06-30 08:38:19.916	2026-07-14 13:02:07.78	cmrknus1v02z14hleh3ioyxxq	ORIGINAL
cmrknuv1q03zj4hlenfgvhxba	cmrkbbzjk000amneoowf62wmn	\N	SELL	1900000	2026-06-30 08:38:19.916	2026-07-14 13:02:07.791	cmrknus1v02z14hleh3ioyxxq	HIGH_COPY
cmrknuv2103zn4hlen83yykhs	cmrkbbzjk000amneoowf62wmn	\N	SELL	1200000	2026-06-30 08:38:19.916	2026-07-14 13:02:07.801	cmrknus1v02z14hleh3ioyxxq	COPY
cmrknuv2c03zr4hle8l1lsszf	cmrkbbzjk000amneoowf62wmn	\N	SELL	2500000	2026-06-30 08:38:52.973	2026-07-14 13:02:07.812	cmrknuk4w002l4hlepsz89rxi	ORIGINAL
cmrknuv2o03zv4hlexa7o7r19	cmrkbbzjk000amneoowf62wmn	\N	SELL	1900000	2026-06-30 08:38:52.973	2026-07-14 13:02:07.824	cmrknuk4w002l4hlepsz89rxi	HIGH_COPY
cmrknuv2z03zz4hler0s18qvl	cmrkbbzjk000amneoowf62wmn	\N	SELL	1200000	2026-06-30 08:38:52.973	2026-07-14 13:02:07.835	cmrknuk4w002l4hlepsz89rxi	COPY
cmrknuv3904034hle91j8frht	cmrkbbzjk000amneoowf62wmn	\N	SELL	3900000	2026-06-30 08:39:29.956	2026-07-14 13:02:07.846	cmrknupj9027t4hle7p7wpqj7	ORIGINAL
cmrknuv3l04074hlerti2q120	cmrkbbzjk000amneoowf62wmn	\N	SELL	2600000	2026-06-30 08:39:29.956	2026-07-14 13:02:07.857	cmrknupj9027t4hle7p7wpqj7	HIGH_COPY
cmrknuv3w040b4hlelt7ctnnb	cmrkbbzjk000amneoowf62wmn	\N	SELL	1700000	2026-06-30 08:39:29.956	2026-07-14 13:02:07.868	cmrknupj9027t4hle7p7wpqj7	COPY
cmrknuv47040f4hler5au4mlw	cmrkbbzjk000amneoowf62wmn	\N	SELL	2800000	2026-06-30 08:40:10.262	2026-07-14 13:02:07.879	cmrknurun02wx4hlefzl620dj	ORIGINAL
cmrknuv4j040j4hlew4b65uz0	cmrkbbzjk000amneoowf62wmn	\N	SELL	1900000	2026-06-30 08:40:10.262	2026-07-14 13:02:07.891	cmrknurun02wx4hlefzl620dj	HIGH_COPY
cmrknuv4u040n4hlejcttg5zb	cmrkbbzjk000amneoowf62wmn	\N	SELL	1200000	2026-06-30 08:40:10.262	2026-07-14 13:02:07.902	cmrknurun02wx4hlefzl620dj	COPY
cmrknuv56040r4hlew38qbj7w	cmrkbbzjk000amneoowf62wmn	\N	SELL	3900000	2026-06-30 08:40:41.051	2026-07-14 13:02:07.914	cmrknuq5z02e34hlejp111l5i	ORIGINAL
cmrknuv5i040v4hlelzpbrzhi	cmrkbbzjk000amneoowf62wmn	\N	SELL	3100000	2026-06-30 08:40:41.051	2026-07-14 13:02:07.926	cmrknuq5z02e34hlejp111l5i	HIGH_COPY
cmrknuv5u040z4hlekeowopmz	cmrkbbzjk000amneoowf62wmn	\N	SELL	2100000	2026-06-30 08:40:41.051	2026-07-14 13:02:07.938	cmrknuq5z02e34hlejp111l5i	COPY
cmrknuv6504134hlezf46a2az	cmrkbbzjk000amneoowf62wmn	\N	SELL	3800000	2026-06-30 08:41:07.783	2026-07-14 13:02:07.949	cmrknup0o020t4hle1ydhrjrc	ORIGINAL
cmrknuv6h04174hle0sdc403b	cmrkbbzjk000amneoowf62wmn	\N	SELL	2900000	2026-06-30 08:41:07.783	2026-07-14 13:02:07.961	cmrknup0o020t4hle1ydhrjrc	HIGH_COPY
cmrknuv6s041b4hleaaz6yxb2	cmrkbbzjk000amneoowf62wmn	\N	SELL	2200000	2026-06-30 08:41:07.783	2026-07-14 13:02:07.972	cmrknup0o020t4hle1ydhrjrc	COPY
cmrknuv74041f4hlel6ffrn5w	cmrkbbzjk000amneoowf62wmn	\N	SELL	3900000	2026-06-30 08:42:24.571	2026-07-14 13:02:07.984	cmrknunlx019h4hle78wrfxn3	ORIGINAL
cmrknuv7e041j4hlera1xp78l	cmrkbbzjk000amneoowf62wmn	\N	SELL	3050000	2026-06-30 08:42:24.571	2026-07-14 13:02:07.995	cmrknunlx019h4hle78wrfxn3	HIGH_COPY
cmrknuv7r041n4hlemf387nkv	cmrkbbzjk000amneoowf62wmn	\N	SELL	2300000	2026-06-30 08:42:24.571	2026-07-14 13:02:08.007	cmrknunlx019h4hle78wrfxn3	COPY
cmrknuv82041r4hlecmglqmjx	cmrkbbzjk000amneoowf62wmn	\N	SELL	4500000	2026-06-30 08:54:45.403	2026-07-14 13:02:08.019	cmrknukhg008j4hle3cbbnfvr	ORIGINAL
cmrknuv8d041v4hleifqod8kq	cmrkbbzjk000amneoowf62wmn	\N	SELL	3700000	2026-06-30 08:54:45.403	2026-07-14 13:02:08.029	cmrknukhg008j4hle3cbbnfvr	HIGH_COPY
cmrknuv8n041z4hlegp4skk0s	cmrkbbzjk000amneoowf62wmn	\N	SELL	3000000	2026-06-30 08:54:45.403	2026-07-14 13:02:08.04	cmrknukhg008j4hle3cbbnfvr	COPY
cmrknuv8x04234hle0pa1zf4s	cmrkbbzjk000amneoowf62wmn	\N	SELL	4900000	2026-06-30 08:55:41.34	2026-07-14 13:02:08.05	cmrknuslh034x4hle52ouxrh3	ORIGINAL
cmrknuv9804274hle8v0tlb93	cmrkbbzjk000amneoowf62wmn	\N	SELL	4050000	2026-06-30 08:55:41.34	2026-07-14 13:02:08.06	cmrknuslh034x4hle52ouxrh3	HIGH_COPY
cmrknuv9j042b4hlew96m5f4k	cmrkbbzjk000amneoowf62wmn	\N	SELL	3200000	2026-06-30 08:55:41.34	2026-07-14 13:02:08.071	cmrknuslh034x4hle52ouxrh3	COPY
cmrknuv9u042f4hlejo2gnrq1	cmrkbbzjk000amneoowf62wmn	\N	SELL	4900000	2026-06-30 08:56:20.456	2026-07-14 13:02:08.082	cmrknuslb034v4hleeqaes1ky	ORIGINAL
cmrknuva4042j4hlealsx69f1	cmrkbbzjk000amneoowf62wmn	\N	SELL	4050000	2026-06-30 08:56:20.456	2026-07-14 13:02:08.092	cmrknuslb034v4hleeqaes1ky	HIGH_COPY
cmrknuvag042n4hle0vnwgbwd	cmrkbbzjk000amneoowf62wmn	\N	SELL	3200000	2026-06-30 08:56:20.456	2026-07-14 13:02:08.104	cmrknuslb034v4hleeqaes1ky	COPY
cmrknuvar042r4hle13pi12q5	cmrknut0y039h4hlekczcvqvm	\N	SELL	7890000	2026-06-30 09:05:33.953	2026-07-14 13:02:08.116	cmrknuslp034z4hlepmsig8d8	ORIGINAL
cmrknuvb2042v4hle5oqywgnp	cmrknut0y039h4hlekczcvqvm	\N	SELL	5250000	2026-06-30 09:05:33.953	2026-07-14 13:02:08.126	cmrknuslp034z4hlepmsig8d8	HIGH_COPY
cmrknuvbc042z4hle4t85jgd4	cmrknut0y039h4hlekczcvqvm	\N	SELL	2500000	2026-06-30 09:05:33.953	2026-07-14 13:02:08.137	cmrknuslp034z4hlepmsig8d8	COPY
cmrknuvbm04334hlejwvpiw19	cmrknut0y039h4hlekczcvqvm	\N	SELL	19850000	2026-06-30 09:06:34.185	2026-07-14 13:02:08.146	cmrknukj1009x4hle6uioxq9r	ORIGINAL
cmrknuvbx04374hleav4pfwnc	cmrknut0y039h4hlekczcvqvm	\N	SELL	12380000	2026-06-30 09:06:34.185	2026-07-14 13:02:08.157	cmrknukj1009x4hle6uioxq9r	HIGH_COPY
cmrknuvc7043b4hlejz59vk14	cmrknut0y039h4hlekczcvqvm	\N	SELL	6900000	2026-06-30 09:06:34.185	2026-07-14 13:02:08.167	cmrknukj1009x4hle6uioxq9r	COPY
cmrknuvch043f4hlej7ogb4dr	cmrknut0y039h4hlekczcvqvm	\N	SELL	44620000	2026-06-30 09:07:21.854	2026-07-14 13:02:08.178	cmrknusm403534hleg0ak87ub	ORIGINAL
cmrknuvcs043j4hle2cpnrd1o	cmrknut0y039h4hlekczcvqvm	\N	SELL	36700000	2026-06-30 09:07:21.854	2026-07-14 13:02:08.188	cmrknusm403534hleg0ak87ub	HIGH_COPY
cmrknuvd2043n4hlen1rwgvx5	cmrknut0y039h4hlekczcvqvm	\N	SELL	22120000	2026-06-30 09:07:21.854	2026-07-14 13:02:08.199	cmrknusm403534hleg0ak87ub	COPY
cmrknuvdd043r4hleuh4fqwjq	cmrknut0y039h4hlekczcvqvm	\N	SELL	14960000	2026-06-30 09:08:57.376	2026-07-14 13:02:08.209	cmrknuqlf02il4hleobcygeb7	ORIGINAL
cmrknuvdo043v4hle6kk88asd	cmrknut0y039h4hlekczcvqvm	\N	SELL	12400000	2026-06-30 09:08:57.376	2026-07-14 13:02:08.22	cmrknuqlf02il4hleobcygeb7	HIGH_COPY
cmrknuvdx043z4hlep7v3lqxx	cmrknut0y039h4hlekczcvqvm	\N	SELL	3800000	2026-06-30 09:08:57.376	2026-07-14 13:02:08.229	cmrknuqlf02il4hleobcygeb7	COPY
cmrknuve704434hle2am8739r	cmrknut0y039h4hlekczcvqvm	\N	SELL	57380000	2026-06-30 09:10:00.756	2026-07-14 13:02:08.24	cmrknuk9x00554hle9um1cc7q	ORIGINAL
cmrknuvei04474hleewwu43vt	cmrknut0y039h4hlekczcvqvm	\N	SELL	52400000	2026-06-30 09:10:00.756	2026-07-14 13:02:08.25	cmrknuk9x00554hle9um1cc7q	HIGH_COPY
cmrknuveu044b4hlek3rkgoxw	cmrknut0y039h4hlekczcvqvm	\N	SELL	41000000	2026-06-30 09:10:00.756	2026-07-14 13:02:08.262	cmrknuk9x00554hle9um1cc7q	COPY
cmrknuvf5044f4hle1snblrr5	cmrknut0y039h4hlekczcvqvm	\N	SELL	49800000	2026-06-30 09:10:50.757	2026-07-14 13:02:08.273	cmrknuki100914hleaxh4lulp	ORIGINAL
cmrknuvfg044j4hlesdlzbx5l	cmrknut0y039h4hlekczcvqvm	\N	SELL	41500000	2026-06-30 09:10:50.757	2026-07-14 13:02:08.284	cmrknuki100914hleaxh4lulp	HIGH_COPY
cmrknuvfq044n4hleer5op0zg	cmrknut0y039h4hlekczcvqvm	\N	SELL	34600000	2026-06-30 09:10:50.757	2026-07-14 13:02:08.295	cmrknuki100914hleaxh4lulp	COPY
cmrknuvg1044r4hle994gfv26	cmrknut0y039h4hlekczcvqvm	\N	SELL	2950000	2026-06-30 09:12:03.784	2026-07-14 13:02:08.305	cmrknurr502vx4hle7a5jpm1p	ORIGINAL
cmrknuvgd044v4hle5x8v6v3c	cmrknut0y039h4hlekczcvqvm	\N	SELL	1690000	2026-06-30 09:12:03.784	2026-07-14 13:02:08.317	cmrknurr502vx4hle7a5jpm1p	HIGH_COPY
cmrknuvgn044z4hle294bn6xi	cmrknut0y039h4hlekczcvqvm	\N	SELL	1100000	2026-06-30 09:12:03.784	2026-07-14 13:02:08.328	cmrknurr502vx4hle7a5jpm1p	COPY
cmrknuvgz04534hlezidfloqn	cmrknut0y039h4hlekczcvqvm	\N	SELL	3680000	2026-06-30 09:12:34.904	2026-07-14 13:02:08.339	cmrknuk50002n4hlevq2b3czx	ORIGINAL
cmrknuvhb04574hle2llmvjzk	cmrknut0y039h4hlekczcvqvm	\N	SELL	2730000	2026-06-30 09:12:34.904	2026-07-14 13:02:08.351	cmrknuk50002n4hlevq2b3czx	HIGH_COPY
cmrknuvhn045b4hlexplav6pn	cmrknut0y039h4hlekczcvqvm	\N	SELL	1700000	2026-06-30 09:12:34.904	2026-07-14 13:02:08.363	cmrknuk50002n4hlevq2b3czx	COPY
cmrknuvhz045f4hlemu4m9ug5	cmrknut0y039h4hlekczcvqvm	\N	SELL	3620000	2026-06-30 09:13:08.992	2026-07-14 13:02:08.375	cmrknuk7e003x4hleakqib6r2	ORIGINAL
cmrknuvia045j4hlemrhy4vk2	cmrknut0y039h4hlekczcvqvm	\N	SELL	2890000	2026-06-30 09:13:08.992	2026-07-14 13:02:08.387	cmrknuk7e003x4hleakqib6r2	HIGH_COPY
cmrknuvim045n4hlea84bzy6t	cmrknut0y039h4hlekczcvqvm	\N	SELL	1700000	2026-06-30 09:13:08.992	2026-07-14 13:02:08.398	cmrknuk7e003x4hleakqib6r2	COPY
cmrknuvix045r4hleu60j8vkj	cmrknut0y039h4hlekczcvqvm	\N	SELL	7880000	2026-06-30 09:14:46.055	2026-07-14 13:02:08.41	cmrknurjw02tr4hlevgx3re8a	ORIGINAL
cmrknuvj9045v4hle275172zj	cmrknut0y039h4hlekczcvqvm	\N	SELL	5780000	2026-06-30 09:14:46.055	2026-07-14 13:02:08.421	cmrknurjw02tr4hlevgx3re8a	HIGH_COPY
cmrknuvjk045z4hlejmj1p65j	cmrknut0y039h4hlekczcvqvm	\N	SELL	1900000	2026-06-30 09:14:46.055	2026-07-14 13:02:08.433	cmrknurjw02tr4hlevgx3re8a	COPY
cmrknuvjw04634hlei5w6klxr	cmrknut0y039h4hlekczcvqvm	\N	SELL	3750000	2026-06-30 09:15:40.942	2026-07-14 13:02:08.444	cmrknurv702x34hle7iu4ikqt	ORIGINAL
cmrknuvk804674hlekcgpc1hp	cmrknut0y039h4hlekczcvqvm	\N	SELL	2900000	2026-06-30 09:15:40.942	2026-07-14 13:02:08.456	cmrknurv702x34hle7iu4ikqt	HIGH_COPY
cmrknuvkk046b4hleeqezozvc	cmrknut0y039h4hlekczcvqvm	\N	SELL	1600000	2026-06-30 09:15:40.942	2026-07-14 13:02:08.468	cmrknurv702x34hle7iu4ikqt	COPY
cmrknuvkv046f4hlekkvno2l4	cmrknut0y039h4hlekczcvqvm	\N	SELL	13320000	2026-06-30 09:18:43.676	2026-07-14 13:02:08.479	cmrknurjk02tl4hle7am0uqrf	ORIGINAL
cmrknuvl7046j4hlekf6vin99	cmrknut0y039h4hlekczcvqvm	\N	SELL	8590000	2026-06-30 09:18:43.676	2026-07-14 13:02:08.491	cmrknurjk02tl4hle7am0uqrf	HIGH_COPY
cmrknuvlj046n4hle5rxyoth9	cmrknut0y039h4hlekczcvqvm	\N	SELL	2200000	2026-06-30 09:18:43.676	2026-07-14 13:02:08.503	cmrknurjk02tl4hle7am0uqrf	COPY
cmrknuvlu046r4hlez5sfaeav	cmrknut0y039h4hlekczcvqvm	\N	SELL	11980000	2026-06-30 09:19:14.02	2026-07-14 13:02:08.514	cmrknukf5006z4hleqkmh6fuc	ORIGINAL
cmrknuvm5046v4hleyner2a4n	cmrknut0y039h4hlekczcvqvm	\N	SELL	9450000	2026-06-30 09:19:14.02	2026-07-14 13:02:08.526	cmrknukf5006z4hleqkmh6fuc	HIGH_COPY
cmrknuvmi046z4hler9cjybct	cmrknut0y039h4hlekczcvqvm	\N	SELL	2300000	2026-06-30 09:19:14.02	2026-07-14 13:02:08.538	cmrknukf5006z4hleqkmh6fuc	COPY
cmrknuvms04734hle313cgnkf	cmrknut0y039h4hlekczcvqvm	\N	SELL	15980000	2026-06-30 09:21:26.445	2026-07-14 13:02:08.549	cmrknukge007t4hle7nzd1gba	ORIGINAL
cmrknuvn404774hleqrw2lsg9	cmrknut0y039h4hlekczcvqvm	\N	SELL	12400000	2026-06-30 09:21:26.445	2026-07-14 13:02:08.56	cmrknukge007t4hle7nzd1gba	HIGH_COPY
cmrknuvnf047b4hletfitddfj	cmrknut0y039h4hlekczcvqvm	\N	SELL	3300000	2026-06-30 09:21:26.445	2026-07-14 13:02:08.572	cmrknukge007t4hle7nzd1gba	COPY
cmrknuvnr047f4hletscg9bfq	cmrknut0y039h4hlekczcvqvm	\N	SELL	16900000	2026-06-30 09:26:24.849	2026-07-14 13:02:08.583	cmrknuo7k01g54hleyba4r0x1	ORIGINAL
cmrknuvo2047j4hle33xw5p79	cmrknut0y039h4hlekczcvqvm	\N	SELL	13750000	2026-06-30 09:26:24.849	2026-07-14 13:02:08.594	cmrknuo7k01g54hleyba4r0x1	HIGH_COPY
cmrknuvod047n4hleibivftyy	cmrknut0y039h4hlekczcvqvm	\N	SELL	6100000	2026-06-30 09:26:24.849	2026-07-14 13:02:08.606	cmrknuo7k01g54hleyba4r0x1	COPY
cmrknuvop047r4hleh1h0yj4m	cmrknut0y039h4hlekczcvqvm	\N	SELL	15450000	2026-06-30 09:27:08.501	2026-07-14 13:02:08.618	cmrknuool01r74hle77xz53b6	ORIGINAL
cmrknuvp0047v4hleku09jiqz	cmrknut0y039h4hlekczcvqvm	\N	SELL	12300000	2026-06-30 09:27:08.501	2026-07-14 13:02:08.628	cmrknuool01r74hle77xz53b6	HIGH_COPY
cmrknuvpb047z4hlekdtxgalu	cmrknut0y039h4hlekczcvqvm	\N	SELL	3200000	2026-06-30 09:27:08.501	2026-07-14 13:02:08.64	cmrknuool01r74hle77xz53b6	COPY
cmrknuvpn04834hle4wx2vyh9	cmrknut0y039h4hlekczcvqvm	\N	SELL	13500000	2026-06-30 09:29:14.027	2026-07-14 13:02:08.651	cmrknuntm01bf4hledensl08i	ORIGINAL
cmrknuvpy04874hle8dc5gm94	cmrknut0y039h4hlekczcvqvm	\N	SELL	10400000	2026-06-30 09:29:14.027	2026-07-14 13:02:08.662	cmrknuntm01bf4hledensl08i	HIGH_COPY
cmrknuvq8048b4hleym27puze	cmrknut0y039h4hlekczcvqvm	\N	SELL	3200000	2026-06-30 09:29:14.027	2026-07-14 13:02:08.673	cmrknuntm01bf4hledensl08i	COPY
cmrknuvqi048f4hleuonfvouv	cmrknut0y039h4hlekczcvqvm	\N	SELL	3150000	2026-06-30 09:31:08.293	2026-07-14 13:02:08.683	cmrknurim02sv4hlebagnkftr	ORIGINAL
cmrknuvqt048j4hlec2urfrmm	cmrknut0y039h4hlekczcvqvm	\N	SELL	2480000	2026-06-30 09:31:08.293	2026-07-14 13:02:08.694	cmrknurim02sv4hlebagnkftr	HIGH_COPY
cmrknuvr4048n4hlen85kmwnj	cmrknut0y039h4hlekczcvqvm	\N	SELL	1500000	2026-06-30 09:31:08.293	2026-07-14 13:02:08.704	cmrknurim02sv4hlebagnkftr	COPY
cmrknuvrf048r4hlekqvgz6nn	cmrknut0y039h4hlekczcvqvm	\N	SELL	3470000	2026-06-30 09:31:44.741	2026-07-14 13:02:08.715	cmrknuncs016r4hlesbt036xz	ORIGINAL
cmrknuvrq048v4hlecdixs75k	cmrknut0y039h4hlekczcvqvm	\N	SELL	2650000	2026-06-30 09:31:44.741	2026-07-14 13:02:08.726	cmrknuncs016r4hlesbt036xz	HIGH_COPY
cmrknuvs0048z4hle86wgy2kw	cmrknut0y039h4hlekczcvqvm	\N	SELL	1700000	2026-06-30 09:31:44.741	2026-07-14 13:02:08.736	cmrknuncs016r4hlesbt036xz	COPY
cmrknuvsa04934hle5x01aif6	cmrknut0y039h4hlekczcvqvm	\N	SELL	39000000	2026-06-30 09:33:41.687	2026-07-14 13:02:08.746	cmrknumbm00w54hlee8bpngkh	ORIGINAL
cmrknuvsk04974hleoxpt6lhi	cmrknut0y039h4hlekczcvqvm	\N	SELL	35600000	2026-06-30 09:33:41.687	2026-07-14 13:02:08.757	cmrknumbm00w54hlee8bpngkh	HIGH_COPY
cmrknuvsv049b4hlecq809bg6	cmrknut0y039h4hlekczcvqvm	\N	SELL	31200000	2026-06-30 09:33:41.687	2026-07-14 13:02:08.767	cmrknumbm00w54hlee8bpngkh	COPY
cmrknuvt5049f4hlenoherqm5	cmrknut0y039h4hlekczcvqvm	\N	SELL	3470000	2026-06-30 10:09:55.035	2026-07-14 13:02:08.777	cmrknusmh03574hleaoy1wipc	ORIGINAL
cmrknuvtf049j4hle89jbiefn	cmrknut0y039h4hlekczcvqvm	\N	SELL	2320000	2026-06-30 10:09:55.035	2026-07-14 13:02:08.787	cmrknusmh03574hleaoy1wipc	HIGH_COPY
cmrknuvtq049n4hlezbymdk82	cmrknut0y039h4hlekczcvqvm	\N	SELL	1300000	2026-06-30 10:09:55.035	2026-07-14 13:02:08.798	cmrknusmh03574hleaoy1wipc	COPY
cmrknuvu2049r4hle7p4cillt	cmrknut0y039h4hlekczcvqvm	\N	SELL	5670000	2026-06-30 10:10:49.123	2026-07-14 13:02:08.81	cmrknusmw035b4hletixi9cgt	ORIGINAL
cmrknuvue049v4hle8nk3t3qc	cmrknut0y039h4hlekczcvqvm	\N	SELL	4520000	2026-06-30 10:10:49.123	2026-07-14 13:02:08.822	cmrknusmw035b4hletixi9cgt	HIGH_COPY
cmrknuvur049z4hleku2k3t91	cmrknut0y039h4hlekczcvqvm	\N	SELL	1700000	2026-06-30 10:10:49.123	2026-07-14 13:02:08.835	cmrknusmw035b4hletixi9cgt	COPY
cmrknuvv204a34hleczfyot3w	cmrknut0y039h4hlekczcvqvm	\N	SELL	10970000	2026-06-30 10:11:26.63	2026-07-14 13:02:08.847	cmrknusn8035f4hle12ofknao	ORIGINAL
cmrknuvvf04a74hleq1w3wbcv	cmrknut0y039h4hlekczcvqvm	\N	SELL	8500000	2026-06-30 10:11:26.63	2026-07-14 13:02:08.859	cmrknusn8035f4hle12ofknao	HIGH_COPY
cmrknuvvt04ab4hlehonpc4nl	cmrknut0y039h4hlekczcvqvm	\N	SELL	3900000	2026-06-30 10:11:26.63	2026-07-14 13:02:08.873	cmrknusn8035f4hle12ofknao	COPY
cmrknuvw504af4hlec3n25n0d	cmrknut0y039h4hlekczcvqvm	\N	SELL	15820000	2026-06-30 10:11:54.737	2026-07-14 13:02:08.885	cmrknusnf035h4hleqjp3o4de	ORIGINAL
cmrknuvwh04aj4hle4mdmgppf	cmrknut0y039h4hlekczcvqvm	\N	SELL	12800000	2026-06-30 10:11:54.737	2026-07-14 13:02:08.897	cmrknusnf035h4hleqjp3o4de	HIGH_COPY
cmrknuvwu04an4hle1uiij7tm	cmrknut0y039h4hlekczcvqvm	\N	SELL	6300000	2026-06-30 10:11:54.737	2026-07-14 13:02:08.91	cmrknusnf035h4hleqjp3o4de	COPY
cmrknuvx704ar4hlex223uzj5	cmrknut0y039h4hlekczcvqvm	\N	SELL	12800000	2026-07-08 08:13:25.25	2026-07-14 13:02:08.923	cmrknurje02th4hleej2cm8uw	ORIGINAL
cmrknuvxk04av4hler5xlacit	cmrknut0y039h4hlekczcvqvm	\N	SELL	10200000	2026-07-08 08:13:25.25	2026-07-14 13:02:08.936	cmrknurje02th4hleej2cm8uw	HIGH_COPY
cmrknuvxx04az4hlei5qh38iw	cmrknut0y039h4hlekczcvqvm	\N	SELL	3500000	2026-07-08 08:13:25.25	2026-07-14 13:02:08.949	cmrknurje02th4hleej2cm8uw	COPY
cmrknuvya04b34hleoim51d0m	cmrknut0y039h4hlekczcvqvm	\N	SELL	3870000	2026-06-30 10:12:35.211	2026-07-14 13:02:08.962	cmrknusnn035j4hlemqflbimg	ORIGINAL
cmrknuvyn04b74hleiao6fatt	cmrknut0y039h4hlekczcvqvm	\N	SELL	2720000	2026-06-30 10:12:35.211	2026-07-14 13:02:08.976	cmrknusnn035j4hlemqflbimg	HIGH_COPY
cmrknuvz104bb4hle8o7141z9	cmrknut0y039h4hlekczcvqvm	\N	SELL	1300000	2026-06-30 10:12:35.211	2026-07-14 13:02:08.989	cmrknusnn035j4hlemqflbimg	COPY
cmrknuvze04bf4hle343cd1dy	cmrknut0y039h4hlekczcvqvm	\N	SELL	5670000	2026-06-30 10:13:04.945	2026-07-14 13:02:09.002	cmrknusnt035l4hle78ull8hq	ORIGINAL
cmrknuvzq04bj4hleepy91w4j	cmrknut0y039h4hlekczcvqvm	\N	SELL	4500000	2026-06-30 10:13:04.945	2026-07-14 13:02:09.014	cmrknusnt035l4hle78ull8hq	HIGH_COPY
cmrknuw0004bn4hlerm0hjpq3	cmrknut0y039h4hlekczcvqvm	\N	SELL	1800000	2026-06-30 10:13:04.945	2026-07-14 13:02:09.024	cmrknusnt035l4hle78ull8hq	COPY
cmrknuw0b04br4hle8e6m1xaa	cmrknut0y039h4hlekczcvqvm	\N	SELL	13950000	2026-06-30 10:13:37.5	2026-07-14 13:02:09.035	cmrknuso0035n4hleolzhey0f	ORIGINAL
cmrknuw0l04bv4hleyw89attz	cmrknut0y039h4hlekczcvqvm	\N	SELL	12700000	2026-06-30 10:13:37.5	2026-07-14 13:02:09.045	cmrknuso0035n4hleolzhey0f	HIGH_COPY
cmrknuw0v04bz4hle3z2q4qek	cmrknut0y039h4hlekczcvqvm	\N	SELL	3700000	2026-06-30 10:13:37.5	2026-07-14 13:02:09.056	cmrknuso0035n4hleolzhey0f	COPY
cmrknuw1604c34hlehnwhpdqi	cmrknut0y039h4hlekczcvqvm	\N	SELL	13820000	2026-06-30 10:14:08.124	2026-07-14 13:02:09.066	cmrknuso6035p4hleg1f5s7qh	ORIGINAL
cmrknuw1g04c74hle4u2m63qx	cmrknut0y039h4hlekczcvqvm	\N	SELL	10890000	2026-06-30 10:14:08.124	2026-07-14 13:02:09.076	cmrknuso6035p4hleg1f5s7qh	HIGH_COPY
cmrknuw1r04cb4hlerhuw8vg9	cmrknut0y039h4hlekczcvqvm	\N	SELL	3300000	2026-06-30 10:14:08.124	2026-07-14 13:02:09.088	cmrknuso6035p4hleg1f5s7qh	COPY
cmrknuw2104cf4hlefqemsr68	cmrknut0y039h4hlekczcvqvm	\N	SELL	13890000	2026-06-30 10:14:46.867	2026-07-14 13:02:09.097	cmrknusoc035r4hleikj33a89	ORIGINAL
cmrknuw2d04cj4hlef5mx1qvz	cmrknut0y039h4hlekczcvqvm	\N	SELL	9750000	2026-06-30 10:14:46.867	2026-07-14 13:02:09.11	cmrknusoc035r4hleikj33a89	HIGH_COPY
cmrknuw2q04cn4hlean720w0g	cmrknut0y039h4hlekczcvqvm	\N	SELL	5600000	2026-06-30 10:14:46.867	2026-07-14 13:02:09.122	cmrknusoc035r4hleikj33a89	COPY
cmrknuw3104cr4hle9x56wy24	cmrknut0y039h4hlekczcvqvm	\N	SELL	16280000	2026-06-30 10:15:14.339	2026-07-14 13:02:09.133	cmrknusoj035t4hleeogpfz30	ORIGINAL
cmrknuw3c04cv4hlezyvxzn1c	cmrknut0y039h4hlekczcvqvm	\N	SELL	12800000	2026-06-30 10:15:14.339	2026-07-14 13:02:09.144	cmrknusoj035t4hleeogpfz30	HIGH_COPY
cmrknuw3n04cz4hleaddfexu0	cmrknut0y039h4hlekczcvqvm	\N	SELL	7700000	2026-06-30 10:15:14.339	2026-07-14 13:02:09.155	cmrknusoj035t4hleeogpfz30	COPY
cmrknuw3z04d34hle0c5nistp	cmrknut0y039h4hlekczcvqvm	\N	SELL	17300000	2026-06-30 10:15:44.703	2026-07-14 13:02:09.167	cmrknusop035v4hley486zzxx	ORIGINAL
cmrknuw4a04d74hlehjybcd9x	cmrknut0y039h4hlekczcvqvm	\N	SELL	13650000	2026-06-30 10:15:44.703	2026-07-14 13:02:09.178	cmrknusop035v4hley486zzxx	HIGH_COPY
cmrknuw4n04db4hleaxi01hev	cmrknut0y039h4hlekczcvqvm	\N	SELL	7400000	2026-06-30 10:15:44.703	2026-07-14 13:02:09.191	cmrknusop035v4hley486zzxx	COPY
cmrknuw5004df4hlefsip5i3q	cmrknut0y039h4hlekczcvqvm	\N	SELL	29650000	2026-06-30 10:16:22.373	2026-07-14 13:02:09.204	cmrknusow035x4hle8qsksmw6	ORIGINAL
cmrknuw5c04dj4hledwat4ia7	cmrknut0y039h4hlekczcvqvm	\N	SELL	25200000	2026-06-30 10:16:22.373	2026-07-14 13:02:09.216	cmrknusow035x4hle8qsksmw6	HIGH_COPY
cmrknuw5o04dn4hlej4oyt3j4	cmrknut0y039h4hlekczcvqvm	\N	SELL	17400000	2026-06-30 10:16:22.373	2026-07-14 13:02:09.228	cmrknusow035x4hle8qsksmw6	COPY
cmrknuw5z04dr4hle4q20a1yh	cmrknut0y039h4hlekczcvqvm	\N	SELL	44770000	2026-06-30 10:16:55.284	2026-07-14 13:02:09.24	cmrknusp2035z4hlez222qrow	ORIGINAL
cmrknuw6b04dv4hle306nrxhg	cmrknut0y039h4hlekczcvqvm	\N	SELL	38450000	2026-06-30 10:16:55.284	2026-07-14 13:02:09.251	cmrknusp2035z4hlez222qrow	HIGH_COPY
cmrknuw6o04dz4hlewc8wqvyz	cmrknut0y039h4hlekczcvqvm	\N	SELL	17500000	2026-06-30 10:16:55.284	2026-07-14 13:02:09.264	cmrknusp2035z4hlez222qrow	COPY
cmrknuw7304e34hle58rc1j5s	cmrknut0y039h4hlekczcvqvm	\N	SELL	25820000	2026-06-30 10:18:53.915	2026-07-14 13:02:09.279	cmrknusp803614hlevjl6o0vn	ORIGINAL
cmrknuw7f04e74hleewueok2y	cmrknut0y039h4hlekczcvqvm	\N	SELL	42720000	2026-06-30 10:24:44.03	2026-07-14 13:02:09.291	cmrknuspf03634hleilvfe3ei	ORIGINAL
cmrknuw7t04eb4hlekln5y8wf	cmrknut0y039h4hlekczcvqvm	\N	SELL	40280000	2026-06-30 10:24:44.03	2026-07-14 13:02:09.305	cmrknuspf03634hleilvfe3ei	HIGH_COPY
cmrknuw8904ef4hles7tklz1p	cmrknut0y039h4hlekczcvqvm	\N	SELL	38300000	2026-06-30 10:24:44.03	2026-07-14 13:02:09.321	cmrknuspf03634hleilvfe3ei	COPY
cmrknuw8m04ej4hlepfts6zex	cmrknut0y039h4hlekczcvqvm	\N	SELL	19750000	2026-06-30 10:25:24.058	2026-07-14 13:02:09.334	cmrknuspm03654hleoyv47b5y	ORIGINAL
cmrknuw8y04en4hlezw5r6pvc	cmrknut0y039h4hlekczcvqvm	\N	SELL	18150000	2026-06-30 10:25:24.058	2026-07-14 13:02:09.346	cmrknuspm03654hleoyv47b5y	HIGH_COPY
cmrknuw9b04er4hlel34mq5k1	cmrknut0y039h4hlekczcvqvm	\N	SELL	11100000	2026-06-30 10:25:24.058	2026-07-14 13:02:09.359	cmrknuspm03654hleoyv47b5y	COPY
cmrknuw9q04ev4hleqm2fizx3	cmrknut0y039h4hlekczcvqvm	\N	SELL	21800000	2026-06-30 10:25:55.314	2026-07-14 13:02:09.374	cmrknusps03674hle1xby3sxk	ORIGINAL
cmrknuwa204ez4hlek2tdocey	cmrknut0y039h4hlekczcvqvm	\N	SELL	19380000	2026-06-30 10:25:55.314	2026-07-14 13:02:09.386	cmrknusps03674hle1xby3sxk	HIGH_COPY
cmrknuwaf04f34hle9pd70j7y	cmrknut0y039h4hlekczcvqvm	\N	SELL	16300000	2026-06-30 10:25:55.314	2026-07-14 13:02:09.399	cmrknusps03674hle1xby3sxk	COPY
cmrknuwas04f74hle50c2y77w	cmrknut0y039h4hlekczcvqvm	\N	SELL	17850000	2026-06-30 10:27:05.436	2026-07-14 13:02:09.412	cmrknusq4036b4hleg1l3l7hs	ORIGINAL
cmrknuwb304fb4hle3ph6dkcu	cmrknut0y039h4hlekczcvqvm	\N	SELL	6780000	2026-06-30 10:27:05.436	2026-07-14 13:02:09.424	cmrknusq4036b4hleg1l3l7hs	HIGH_COPY
cmrknuwbf04ff4hlen458lp3h	cmrknut0y039h4hlekczcvqvm	\N	SELL	2800000	2026-06-30 10:27:05.436	2026-07-14 13:02:09.435	cmrknusq4036b4hleg1l3l7hs	COPY
cmrknuwbp04fj4hlefr40b3qe	cmrknut0y039h4hlekczcvqvm	\N	SELL	3980000	2026-06-30 10:34:35.427	2026-07-14 13:02:09.446	cmrknusqb036d4hlea4u93slk	ORIGINAL
cmrknuwc104fn4hlem061q5sq	cmrknut0y039h4hlekczcvqvm	\N	SELL	2700000	2026-06-30 10:34:35.427	2026-07-14 13:02:09.457	cmrknusqb036d4hlea4u93slk	HIGH_COPY
cmrknuwcb04fr4hlexba1z2xe	cmrknut0y039h4hlekczcvqvm	\N	SELL	1500000	2026-06-30 10:34:35.427	2026-07-14 13:02:09.468	cmrknusqb036d4hlea4u93slk	COPY
cmrknuwcm04fv4hlejrggserv	cmrknut0y039h4hlekczcvqvm	\N	SELL	6250000	2026-06-30 10:35:17.996	2026-07-14 13:02:09.478	cmrknusqu036j4hleuajdop36	ORIGINAL
cmrknuwcy04fz4hledlxsq7oy	cmrknut0y039h4hlekczcvqvm	\N	SELL	4300000	2026-06-30 10:35:17.996	2026-07-14 13:02:09.49	cmrknusqu036j4hleuajdop36	HIGH_COPY
cmrknuwd904g34hle51d4ncfx	cmrknut0y039h4hlekczcvqvm	\N	SELL	3750000	2026-06-30 10:35:46	2026-07-14 13:02:09.502	cmrknusr0036l4hleezwyyicq	ORIGINAL
cmrknuwdk04g74hlegyxsdar4	cmrknut0y039h4hlekczcvqvm	\N	SELL	2500000	2026-06-30 10:35:46	2026-07-14 13:02:09.513	cmrknusr0036l4hleezwyyicq	HIGH_COPY
cmrknuwdy04gb4hlev2b4t7ho	cmrknut0y039h4hlekczcvqvm	\N	SELL	1800000	2026-06-30 10:35:46	2026-07-14 13:02:09.526	cmrknusr0036l4hleezwyyicq	COPY
cmrknuwe904gf4hley3q1d44m	cmrknut0y039h4hlekczcvqvm	\N	SELL	4220000	2026-06-30 10:36:15.672	2026-07-14 13:02:09.538	cmrknusr7036n4hleswn41n1q	ORIGINAL
cmrknuwek04gj4hletm7pkyen	cmrknut0y039h4hlekczcvqvm	\N	SELL	2950000	2026-06-30 10:36:15.672	2026-07-14 13:02:09.548	cmrknusr7036n4hleswn41n1q	HIGH_COPY
cmrknuwew04gn4hles680v9cl	cmrknut0y039h4hlekczcvqvm	\N	SELL	2000000	2026-06-30 10:36:15.672	2026-07-14 13:02:09.56	cmrknusr7036n4hleswn41n1q	COPY
cmrknuwf704gr4hlew6pay5a3	cmrknut0y039h4hlekczcvqvm	\N	SELL	4620000	2026-06-30 10:36:51.226	2026-07-14 13:02:09.571	cmrknusrd036p4hlembnt5b04	ORIGINAL
cmrknuwfj04gv4hle3rf27274	cmrknut0y039h4hlekczcvqvm	\N	SELL	3780000	2026-06-30 10:36:51.226	2026-07-14 13:02:09.583	cmrknusrd036p4hlembnt5b04	HIGH_COPY
cmrknuwfu04gz4hle5yqbr06n	cmrknut0y039h4hlekczcvqvm	\N	SELL	2400000	2026-06-30 10:36:51.226	2026-07-14 13:02:09.594	cmrknusrd036p4hlembnt5b04	COPY
cmrknuwg504h34hleqkqa6dfq	cmrknut0y039h4hlekczcvqvm	\N	SELL	37620000	2026-06-30 10:37:25.908	2026-07-14 13:02:09.606	cmrknusrj036r4hledswso0c4	ORIGINAL
cmrknuwgh04h74hlefconi1g1	cmrknut0y039h4hlekczcvqvm	\N	SELL	33640000	2026-06-30 10:37:25.908	2026-07-14 13:02:09.617	cmrknusrj036r4hledswso0c4	HIGH_COPY
cmrknuwgs04hb4hlee7ajn7j4	cmrknut0y039h4hlekczcvqvm	\N	SELL	14500000	2026-06-30 10:37:25.908	2026-07-14 13:02:09.628	cmrknusrj036r4hledswso0c4	COPY
cmrknuwh304hf4hle0mwxwc78	cmrknut0y039h4hlekczcvqvm	\N	SELL	15280000	2026-06-30 10:39:09.759	2026-07-14 13:02:09.639	cmrknusv9037v4hlehq251mx1	ORIGINAL
cmrknuwhf04hj4hles260ebet	cmrknut0y039h4hlekczcvqvm	\N	SELL	12340000	2026-06-30 10:39:09.759	2026-07-14 13:02:09.651	cmrknusv9037v4hlehq251mx1	HIGH_COPY
cmrknuwhq04hn4hle1kumyfri	cmrknut0y039h4hlekczcvqvm	\N	SELL	2900000	2026-06-30 10:39:09.759	2026-07-14 13:02:09.662	cmrknusv9037v4hlehq251mx1	COPY
cmrknuwi104hr4hlela6znle7	cmrknut0y039h4hlekczcvqvm	\N	SELL	14950000	2026-06-30 10:39:55.154	2026-07-14 13:02:09.673	cmrknusrw036v4hle6f1q2krx	ORIGINAL
cmrknuwic04hv4hle88e88qy5	cmrknut0y039h4hlekczcvqvm	\N	SELL	12300000	2026-06-30 10:39:55.154	2026-07-14 13:02:09.685	cmrknusrw036v4hle6f1q2krx	HIGH_COPY
cmrknuwin04hz4hleeqkiqx0c	cmrknut0y039h4hlekczcvqvm	\N	SELL	2800000	2026-06-30 10:39:55.154	2026-07-14 13:02:09.696	cmrknusrw036v4hle6f1q2krx	COPY
cmrknuwiz04i34hlee46b6fap	cmrknut0y039h4hlekczcvqvm	\N	SELL	15380000	2026-06-30 10:40:22.848	2026-07-14 13:02:09.707	cmrknuss3036x4hlelrl3bhex	ORIGINAL
cmrknuwjb04i74hleuh49wmi8	cmrknut0y039h4hlekczcvqvm	\N	SELL	12400000	2026-06-30 10:40:22.848	2026-07-14 13:02:09.719	cmrknuss3036x4hlelrl3bhex	HIGH_COPY
cmrknuwjl04ib4hled4wwckct	cmrknut0y039h4hlekczcvqvm	\N	SELL	2800000	2026-06-30 10:40:22.848	2026-07-14 13:02:09.729	cmrknuss3036x4hlelrl3bhex	COPY
cmrknuwjw04if4hleuf67zu11	cmrknut0y039h4hlekczcvqvm	\N	SELL	15200000	2026-06-30 10:41:18.603	2026-07-14 13:02:09.74	cmrknussa036z4hlef4q2ewac	ORIGINAL
cmrknuwk704ij4hlei5l9r7l5	cmrknut0y039h4hlekczcvqvm	\N	SELL	12550000	2026-06-30 10:41:18.603	2026-07-14 13:02:09.752	cmrknussa036z4hlef4q2ewac	HIGH_COPY
cmrknuwki04in4hlejo7j9t6a	cmrknut0y039h4hlekczcvqvm	\N	SELL	5200000	2026-06-30 10:41:18.603	2026-07-14 13:02:09.762	cmrknussa036z4hlef4q2ewac	COPY
cmrknuwks04ir4hleva6dkgr6	cmrknut0y039h4hlekczcvqvm	\N	SELL	15400000	2026-06-30 10:41:51.759	2026-07-14 13:02:09.772	cmrknussg03714hlezpyagt86	ORIGINAL
cmrknuwl204iv4hle60jo2mxb	cmrknut0y039h4hlekczcvqvm	\N	SELL	13600000	2026-06-30 10:41:51.759	2026-07-14 13:02:09.783	cmrknussg03714hlezpyagt86	HIGH_COPY
cmrknuwld04iz4hleqzdqefug	cmrknut0y039h4hlekczcvqvm	\N	SELL	3600000	2026-06-30 10:41:51.759	2026-07-14 13:02:09.794	cmrknussg03714hlezpyagt86	COPY
cmrknuwlp04j34hleqhofvz35	cmrknut0y039h4hlekczcvqvm	\N	SELL	15380000	2026-06-30 10:42:26.734	2026-07-14 13:02:09.805	cmrknussn03734hle6r8s27ea	ORIGINAL
cmrknuwm004j74hleoo5wv7dp	cmrknut0y039h4hlekczcvqvm	\N	SELL	12400000	2026-06-30 10:42:26.734	2026-07-14 13:02:09.816	cmrknussn03734hle6r8s27ea	HIGH_COPY
cmrknuwma04jb4hle3i1iwo2b	cmrknut0y039h4hlekczcvqvm	\N	SELL	2800000	2026-06-30 10:42:26.734	2026-07-14 13:02:09.827	cmrknussn03734hle6r8s27ea	COPY
cmrknuwml04jf4hleh4xwxr21	cmrknut0y039h4hlekczcvqvm	\N	SELL	15380000	2026-06-30 10:42:57.075	2026-07-14 13:02:09.837	cmrknusst03754hle3kxsdkwa	ORIGINAL
cmrknuwmv04jj4hlehr8geicb	cmrknut0y039h4hlekczcvqvm	\N	SELL	12200000	2026-06-30 10:42:57.075	2026-07-14 13:02:09.847	cmrknusst03754hle3kxsdkwa	HIGH_COPY
cmrknuwn604jn4hle8ia2xx9f	cmrknut0y039h4hlekczcvqvm	\N	SELL	2800000	2026-06-30 10:42:57.075	2026-07-14 13:02:09.858	cmrknusst03754hle3kxsdkwa	COPY
cmrknuwnh04jr4hlewe36lhrb	cmrknut0y039h4hlekczcvqvm	\N	SELL	15720000	2026-06-30 10:44:10.154	2026-07-14 13:02:09.869	cmrknust603794hlexsqt4q5q	ORIGINAL
cmrknuwns04jv4hleinlx1tny	cmrknut0y039h4hlekczcvqvm	\N	SELL	12300000	2026-06-30 10:44:10.154	2026-07-14 13:02:09.88	cmrknust603794hlexsqt4q5q	HIGH_COPY
cmrknuwo304jz4hle372o52ww	cmrknut0y039h4hlekczcvqvm	\N	SELL	2800000	2026-06-30 10:44:10.154	2026-07-14 13:02:09.891	cmrknust603794hlexsqt4q5q	COPY
cmrknuwoe04k34hlekg72uv8g	cmrknut0y039h4hlekczcvqvm	\N	SELL	15750000	2026-06-30 10:44:44.966	2026-07-14 13:02:09.903	cmrknustc037b4hlebf3y3nn3	ORIGINAL
cmrknuwoq04k74hleajd70v35	cmrknut0y039h4hlekczcvqvm	\N	SELL	12700000	2026-06-30 10:44:44.966	2026-07-14 13:02:09.914	cmrknustc037b4hlebf3y3nn3	HIGH_COPY
cmrknuwp204kb4hleqte8nu9m	cmrknut0y039h4hlekczcvqvm	\N	SELL	2900000	2026-06-30 10:44:44.966	2026-07-14 13:02:09.926	cmrknustc037b4hlebf3y3nn3	COPY
cmrknuwpd04kf4hle6ye9xxuk	cmrknut0y039h4hlekczcvqvm	\N	SELL	11380000	2026-06-30 10:45:28.978	2026-07-14 13:02:09.937	cmrknusti037d4hlem8kn5scy	ORIGINAL
cmrknuwpp04kj4hlec88oizt3	cmrknut0y039h4hlekczcvqvm	\N	SELL	8500000	2026-06-30 10:45:28.978	2026-07-14 13:02:09.949	cmrknusti037d4hlem8kn5scy	HIGH_COPY
cmrknuwq104kn4hleo2y5ig4f	cmrknut0y039h4hlekczcvqvm	\N	SELL	11550000	2026-06-30 10:45:57.797	2026-07-14 13:02:09.961	cmrknustp037f4hlejrdfo4rn	ORIGINAL
cmrknuwqc04kr4hlertlr2q2i	cmrknut0y039h4hlekczcvqvm	\N	SELL	8900000	2026-06-30 10:45:57.797	2026-07-14 13:02:09.973	cmrknustp037f4hlejrdfo4rn	HIGH_COPY
cmrknuwqn04kv4hle2n4slngw	cmrknut0y039h4hlekczcvqvm	\N	SELL	8680000	2026-06-30 10:50:04.315	2026-07-14 13:02:09.984	cmrknusun037p4hle3s5b6iqe	ORIGINAL
cmrknuwqy04kz4hleex9e5s9d	cmrknut0y039h4hlekczcvqvm	\N	SELL	6500000	2026-06-30 10:50:04.315	2026-07-14 13:02:09.994	cmrknusun037p4hle3s5b6iqe	HIGH_COPY
cmrknuwr904l34hlej8zeubvf	cmrknut0y039h4hlekczcvqvm	\N	SELL	4800000	2026-06-30 10:50:04.315	2026-07-14 13:02:10.006	cmrknusun037p4hle3s5b6iqe	COPY
cmrknuwrk04l74hlee68n57eq	cmrknut0y039h4hlekczcvqvm	\N	SELL	52000000	2026-06-30 10:50:22.347	2026-07-14 13:02:10.017	cmrknusuv037r4hlenwircxkm	ORIGINAL
cmrknuwrv04lb4hlecibqj8ox	cmrknut0y039h4hlekczcvqvm	\N	SELL	5750000	2026-06-30 10:50:50.551	2026-07-14 13:02:10.027	cmrknusv2037t4hlefz4zvbe8	ORIGINAL
cmrknuws604lf4hle20uh51d7	cmrknut0y039h4hlekczcvqvm	\N	SELL	3900000	2026-06-30 10:50:50.551	2026-07-14 13:02:10.038	cmrknusv2037t4hlefz4zvbe8	HIGH_COPY
cmrknuwsg04lj4hleh38u1d0k	cmrknut0y039h4hlekczcvqvm	\N	SELL	1500000	2026-06-30 10:50:50.551	2026-07-14 13:02:10.048	cmrknusv2037t4hlefz4zvbe8	COPY
cmrknuwsr04ln4hlevq7i8mrg	cmrknut0y039h4hlekczcvqvm	\N	SELL	4900000	2026-06-30 12:48:15.55	2026-07-14 13:02:10.059	cmrknurjr02tp4hle9deqpobv	ORIGINAL
cmrknuwt204lr4hlesbjvi6kp	cmrknut0y039h4hlekczcvqvm	\N	SELL	3860000	2026-06-30 12:48:15.55	2026-07-14 13:02:10.071	cmrknurjr02tp4hle9deqpobv	HIGH_COPY
cmrknuwtc04lv4hle8vfnoo6u	cmrknut0y039h4hlekczcvqvm	\N	SELL	1750000	2026-06-30 12:48:15.55	2026-07-14 13:02:10.081	cmrknurjr02tp4hle9deqpobv	COPY
cmrknuwtn04lz4hleqngml04s	cmrknut0y039h4hlekczcvqvm	\N	SELL	10500000	2026-06-30 12:56:18.889	2026-07-14 13:02:10.091	cmrknuro602v34hleg39gtijg	ORIGINAL
cmrknuwtx04m34hle38x3tvm3	cmrknut0y039h4hlekczcvqvm	\N	SELL	6300000	2026-06-30 12:56:18.889	2026-07-14 13:02:10.102	cmrknuro602v34hleg39gtijg	HIGH_COPY
cmrknuwu804m74hleb5fg9dmp	cmrknut0y039h4hlekczcvqvm	\N	SELL	2700000	2026-06-30 12:56:18.889	2026-07-14 13:02:10.113	cmrknuro602v34hleg39gtijg	COPY
cmrknuwuj04mb4hleg727a2ge	cmrknut0y039h4hlekczcvqvm	\N	SELL	5650000	2026-06-30 12:58:06.662	2026-07-14 13:02:10.123	cmrknuq3d02dd4hlesdxwqafp	ORIGINAL
cmrknuwut04mf4hlefdvkm1l7	cmrknut0y039h4hlekczcvqvm	\N	SELL	4750000	2026-06-30 12:58:06.662	2026-07-14 13:02:10.133	cmrknuq3d02dd4hlesdxwqafp	HIGH_COPY
cmrknuwv304mj4hlev5lyfier	cmrknut0y039h4hlekczcvqvm	\N	SELL	2700000	2026-06-30 12:58:06.662	2026-07-14 13:02:10.143	cmrknuq3d02dd4hlesdxwqafp	COPY
cmrknuwve04mn4hle6soxc6k6	cmrknut1l039k4hle0hr62dc5	\N	SELL	11870000	2026-06-30 12:59:13.03	2026-07-14 13:02:10.154	cmrknul6c00h14hleeh8ukjgn	ORIGINAL
cmrknuwvo04mr4hleqxupm90i	cmrknut1l039k4hle0hr62dc5	\N	SELL	7400000	2026-06-30 12:59:13.03	2026-07-14 13:02:10.164	cmrknul6c00h14hleeh8ukjgn	HIGH_COPY
cmrknuwvy04mv4hle6gv9hyex	cmrknut1l039k4hle0hr62dc5	\N	SELL	4300000	2026-06-30 12:59:13.03	2026-07-14 13:02:10.174	cmrknul6c00h14hleeh8ukjgn	COPY
cmrknuww904mz4hlekxiq6npm	cmrknut0y039h4hlekczcvqvm	\N	SELL	11400000	2026-06-30 13:03:34.178	2026-07-14 13:02:10.185	cmrknunm7019l4hle708bakve	ORIGINAL
cmrknuwwj04n34hleis0vglp2	cmrknut0y039h4hlekczcvqvm	\N	SELL	8500000	2026-06-30 13:03:34.178	2026-07-14 13:02:10.195	cmrknunm7019l4hle708bakve	HIGH_COPY
cmrknuwwu04n74hle8fwqjdr6	cmrknut0y039h4hlekczcvqvm	\N	SELL	9850000	2026-06-30 13:04:36.545	2026-07-14 13:02:10.206	cmrknup09020f4hlehk5avgou	ORIGINAL
cmrknuwx404nb4hlemcsng5d2	cmrknut0y039h4hlekczcvqvm	\N	SELL	7200000	2026-06-30 13:04:36.545	2026-07-14 13:02:10.216	cmrknup09020f4hlehk5avgou	HIGH_COPY
cmrknuwxe04nf4hlewozo2778	cmrknut0y039h4hlekczcvqvm	\N	SELL	12350000	2026-06-30 13:06:49.745	2026-07-14 13:02:10.227	cmrknusvh037x4hleu56m0lj2	ORIGINAL
cmrknuwxq04nj4hle2iunwms2	cmrknut0y039h4hlekczcvqvm	\N	SELL	9580000	2026-06-30 13:06:49.745	2026-07-14 13:02:10.238	cmrknusvh037x4hleu56m0lj2	HIGH_COPY
cmrknuwy104nn4hle80yfvf06	cmrknut0y039h4hlekczcvqvm	\N	SELL	6600000	2026-06-30 13:06:49.745	2026-07-14 13:02:10.25	cmrknusvh037x4hleu56m0lj2	COPY
cmrknuwye04nr4hleunkjkp6v	cmrknut0y039h4hlekczcvqvm	\N	SELL	26500000	2026-06-30 13:10:08.436	2026-07-14 13:02:10.262	cmrknusvo037z4hleai24ag2r	ORIGINAL
cmrknuwyq04nv4hlepziy4pt9	cmrknut0y039h4hlekczcvqvm	\N	SELL	23450000	2026-06-30 13:10:08.436	2026-07-14 13:02:10.274	cmrknusvo037z4hleai24ag2r	HIGH_COPY
cmrknuwz104nz4hleu7khub1k	cmrknut0y039h4hlekczcvqvm	\N	SELL	18000000	2026-06-30 13:10:08.436	2026-07-14 13:02:10.285	cmrknusvo037z4hleai24ag2r	COPY
cmrknuwzb04o34hlet8229fzd	cmrknut0y039h4hlekczcvqvm	\N	SELL	7300000	2026-06-30 13:11:59.716	2026-07-14 13:02:10.295	cmrknushc033p4hleezt3rmt8	ORIGINAL
cmrknuwzn04o74hleh0ha0tiz	cmrknut0y039h4hlekczcvqvm	\N	SELL	4850000	2026-06-30 13:11:59.716	2026-07-14 13:02:10.307	cmrknushc033p4hleezt3rmt8	HIGH_COPY
cmrknuwzz04ob4hle2z9yqqf3	cmrknut0y039h4hlekczcvqvm	\N	SELL	2600000	2026-06-30 13:11:59.716	2026-07-14 13:02:10.319	cmrknushc033p4hleezt3rmt8	COPY
cmrknux0a04of4hlera9ry1o9	cmrknut0y039h4hlekczcvqvm	\N	SELL	3200000	2026-06-30 13:12:46.336	2026-07-14 13:02:10.33	cmrknusa7031l4hlese5bukdo	ORIGINAL
cmrknux0l04oj4hleg8qc4tdh	cmrknut0y039h4hlekczcvqvm	\N	SELL	2650000	2026-06-30 13:12:46.336	2026-07-14 13:02:10.341	cmrknusa7031l4hlese5bukdo	HIGH_COPY
cmrknux0w04on4hle3vmk94ih	cmrknut0y039h4hlekczcvqvm	\N	SELL	1700000	2026-06-30 13:12:46.336	2026-07-14 13:02:10.352	cmrknusa7031l4hlese5bukdo	COPY
cmrknux1704or4hlect6sofse	cmrknut0y039h4hlekczcvqvm	\N	SELL	14850000	2026-06-30 13:13:39.073	2026-07-14 13:02:10.364	cmrknus9o031f4hlez60267k2	ORIGINAL
cmrknux1i04ov4hleb9lg7h5t	cmrknut0y039h4hlekczcvqvm	\N	SELL	9600000	2026-06-30 13:13:39.073	2026-07-14 13:02:10.375	cmrknus9o031f4hlez60267k2	HIGH_COPY
cmrknux1u04oz4hle736asmm2	cmrknut0y039h4hlekczcvqvm	\N	SELL	6500000	2026-06-30 13:13:39.073	2026-07-14 13:02:10.386	cmrknus9o031f4hlez60267k2	COPY
cmrknux2504p34hlefxs9wwgz	cmrknut0y039h4hlekczcvqvm	\N	SELL	9850000	2026-06-30 13:26:15.16	2026-07-14 13:02:10.397	cmrknurgc02rn4hlebcu3t21w	ORIGINAL
cmrknux2h04p74hlehl3rs0hi	cmrknut0y039h4hlekczcvqvm	\N	SELL	6800000	2026-06-30 13:26:15.16	2026-07-14 13:02:10.409	cmrknurgc02rn4hlebcu3t21w	HIGH_COPY
cmrknux2s04pb4hle1dnh5ezv	cmrknut0y039h4hlekczcvqvm	\N	SELL	2700000	2026-06-30 13:26:15.16	2026-07-14 13:02:10.42	cmrknurgc02rn4hlebcu3t21w	COPY
cmrknux3404pf4hlen73g6xud	cmrknut0y039h4hlekczcvqvm	\N	SELL	12350000	2026-06-30 13:27:01.365	2026-07-14 13:02:10.432	cmrknuo2401dx4hle2lfbgsiq	ORIGINAL
cmrknux3e04pj4hlep3wn3zfb	cmrknut0y039h4hlekczcvqvm	\N	SELL	10800000	2026-06-30 13:27:01.365	2026-07-14 13:02:10.442	cmrknuo2401dx4hle2lfbgsiq	HIGH_COPY
cmrknux3q04pn4hlek9wyo8pn	cmrknut0y039h4hlekczcvqvm	\N	SELL	3300000	2026-06-30 13:27:01.365	2026-07-14 13:02:10.454	cmrknuo2401dx4hle2lfbgsiq	COPY
cmrknux4204pr4hlewxam2q72	cmrknut0y039h4hlekczcvqvm	\N	SELL	3850000	2026-06-30 13:27:52.384	2026-07-14 13:02:10.466	cmrknusdq032n4hlem7sfwxnc	ORIGINAL
cmrknux4c04pv4hle3lh6ebti	cmrknut0y039h4hlekczcvqvm	\N	SELL	2900000	2026-06-30 13:27:52.384	2026-07-14 13:02:10.477	cmrknusdq032n4hlem7sfwxnc	HIGH_COPY
cmrknux4p04pz4hle4mam5mpy	cmrknut0y039h4hlekczcvqvm	\N	SELL	1750000	2026-06-30 13:27:52.384	2026-07-14 13:02:10.489	cmrknusdq032n4hlem7sfwxnc	COPY
cmrknux5004q34hleeaa2vy8b	cmrknut0y039h4hlekczcvqvm	\N	SELL	3900000	2026-06-30 13:28:45.535	2026-07-14 13:02:10.501	cmrknuq9u02f74hle329ujxnm	ORIGINAL
cmrknux5d04q74hle9ufatov3	cmrknut0y039h4hlekczcvqvm	\N	SELL	2950000	2026-06-30 13:28:45.535	2026-07-14 13:02:10.513	cmrknuq9u02f74hle329ujxnm	HIGH_COPY
cmrknux5n04qb4hle4y5tmuhl	cmrknut0y039h4hlekczcvqvm	\N	SELL	1900000	2026-06-30 13:28:45.535	2026-07-14 13:02:10.523	cmrknuq9u02f74hle329ujxnm	COPY
cmrknux5z04qf4hlezgw4fptw	cmrknut0y039h4hlekczcvqvm	\N	SELL	3500000	2026-06-30 13:30:00.078	2026-07-14 13:02:10.535	cmrknummy00yx4hletupwjz5h	ORIGINAL
cmrknux6a04qj4hleo3bdzbo6	cmrknut0y039h4hlekczcvqvm	\N	SELL	2600000	2026-06-30 13:30:00.078	2026-07-14 13:02:10.546	cmrknummy00yx4hletupwjz5h	HIGH_COPY
cmrknux6m04qn4hleyhhs5b8f	cmrknut0y039h4hlekczcvqvm	\N	SELL	1900000	2026-06-30 13:30:00.078	2026-07-14 13:02:10.558	cmrknummy00yx4hletupwjz5h	COPY
cmrknux6y04qr4hlej1452tjw	cmrknut0y039h4hlekczcvqvm	\N	SELL	3950000	2026-06-30 13:30:49.503	2026-07-14 13:02:10.57	cmrknuomz01pz4hlegs8tgxc2	ORIGINAL
cmrknux7a04qv4hley53l0ki0	cmrknut0y039h4hlekczcvqvm	\N	SELL	2650000	2026-06-30 13:30:49.503	2026-07-14 13:02:10.583	cmrknuomz01pz4hlegs8tgxc2	HIGH_COPY
cmrknux7n04qz4hlekbcffmln	cmrknut0y039h4hlekczcvqvm	\N	SELL	1900000	2026-06-30 13:30:49.503	2026-07-14 13:02:10.595	cmrknuomz01pz4hlegs8tgxc2	COPY
cmrknux8004r34hleyvtbi24k	cmrknut0y039h4hlekczcvqvm	\N	SELL	12200000	2026-06-30 13:39:31.724	2026-07-14 13:02:10.608	cmrknusvv03814hlemw0m7zj2	ORIGINAL
cmrknux8e04r74hlek8yx5vtr	cmrknut0y039h4hlekczcvqvm	\N	SELL	9200000	2026-06-30 13:39:31.724	2026-07-14 13:02:10.622	cmrknusvv03814hlemw0m7zj2	HIGH_COPY
cmrknux8r04rb4hleh0456os9	cmrknut0y039h4hlekczcvqvm	\N	SELL	7800000	2026-06-30 13:39:31.724	2026-07-14 13:02:10.635	cmrknusvv03814hlemw0m7zj2	COPY
cmrknux9404rf4hleetgeq9wa	cmrknut0y039h4hlekczcvqvm	\N	SELL	5380000	2026-06-30 13:40:10.295	2026-07-14 13:02:10.648	cmrknuk88004d4hled5g02jit	ORIGINAL
cmrknux9g04rj4hles1ftah7k	cmrknut0y039h4hlekczcvqvm	\N	SELL	3950000	2026-06-30 13:40:10.295	2026-07-14 13:02:10.66	cmrknuk88004d4hled5g02jit	HIGH_COPY
cmrknux9s04rn4hlef05abaxi	cmrknut0y039h4hlekczcvqvm	\N	SELL	2700000	2026-06-30 13:40:10.295	2026-07-14 13:02:10.672	cmrknuk88004d4hled5g02jit	COPY
cmrknuxa304rr4hle0vfs71ez	cmrknut0y039h4hlekczcvqvm	\N	SELL	3950000	2026-06-30 13:41:11.36	2026-07-14 13:02:10.684	cmrknusc203254hlew2spvu26	ORIGINAL
cmrknuxae04rv4hlesqtcoi28	cmrknut0y039h4hlekczcvqvm	\N	SELL	2720000	2026-06-30 13:41:11.36	2026-07-14 13:02:10.695	cmrknusc203254hlew2spvu26	HIGH_COPY
cmrknuxar04rz4hlemcuckz26	cmrknut0y039h4hlekczcvqvm	\N	SELL	1900000	2026-06-30 13:41:11.36	2026-07-14 13:02:10.707	cmrknusc203254hlew2spvu26	COPY
cmrknuxb204s34hlevdrg91s1	cmrknut0y039h4hlekczcvqvm	\N	SELL	14800000	2026-06-30 13:43:06.382	2026-07-14 13:02:10.719	cmrknus8i03114hletjrabgwq	ORIGINAL
cmrknuxbe04s74hle4mp3myr5	cmrknut0y039h4hlekczcvqvm	\N	SELL	12450000	2026-06-30 13:43:06.382	2026-07-14 13:02:10.73	cmrknus8i03114hletjrabgwq	HIGH_COPY
cmrknuxbq04sb4hlexg4n64m2	cmrknut0y039h4hlekczcvqvm	\N	SELL	2700000	2026-06-30 13:43:06.382	2026-07-14 13:02:10.743	cmrknus8i03114hletjrabgwq	COPY
cmrknuxc204sf4hlepy4igd3c	cmrknut0y039h4hlekczcvqvm	\N	SELL	14850000	2026-06-30 13:43:52.731	2026-07-14 13:02:10.754	cmrknuriw02t34hlegycrtg44	ORIGINAL
cmrknuxcd04sj4hlevq29yt0j	cmrknut0y039h4hlekczcvqvm	\N	SELL	12650000	2026-06-30 13:43:52.731	2026-07-14 13:02:10.765	cmrknuriw02t34hlegycrtg44	HIGH_COPY
cmrknuxco04sn4hlemr2pby9x	cmrknut0y039h4hlekczcvqvm	\N	SELL	2800000	2026-06-30 13:43:52.731	2026-07-14 13:02:10.776	cmrknuriw02t34hlegycrtg44	COPY
cmrknuxcz04sr4hle8a5f5gqp	cmrknut0y039h4hlekczcvqvm	\N	SELL	17700000	2026-07-13 15:06:11.023	2026-07-14 13:02:10.787	cmrknuspy03694hleoblpugdm	ORIGINAL
cmrknuxd904sv4hle1k9i22ps	cmrknut0y039h4hlekczcvqvm	\N	SELL	13800000	2026-07-13 15:06:11.023	2026-07-14 13:02:10.798	cmrknuspy03694hleoblpugdm	HIGH_COPY
cmrknuxdk04sz4hle209lkig0	cmrknut0y039h4hlekczcvqvm	\N	SELL	10200000	2026-07-13 15:06:11.023	2026-07-14 13:02:10.808	cmrknuspy03694hleoblpugdm	COPY
cmrknuxdw04t34hlee5j82v8p	cmrknut0y039h4hlekczcvqvm	\N	SELL	18800000	2026-07-14 09:06:57.566	2026-07-14 13:02:10.82	cmrknuog001kb4hle3xbh9az9	ORIGINAL
cmrknuxe904t74hleaw7678m0	cmrknut0y039h4hlekczcvqvm	\N	SELL	14500000	2026-07-14 09:06:57.566	2026-07-14 13:02:10.833	cmrknuog001kb4hle3xbh9az9	HIGH_COPY
cmrknuxek04tb4hled2brzz5k	cmrknut0y039h4hlekczcvqvm	\N	SELL	12000000	2026-07-14 09:06:57.566	2026-07-14 13:02:10.845	cmrknuog001kb4hle3xbh9az9	COPY
cmrknuxew04tf4hlec2ylay26	cmrknut0y039h4hlekczcvqvm	\N	SELL	14650000	2026-06-30 13:44:52.754	2026-07-14 13:02:10.857	cmrknung7017n4hleej9wufua	ORIGINAL
cmrknuxf804tj4hleap1eqzfg	cmrknut0y039h4hlekczcvqvm	\N	SELL	12400000	2026-06-30 13:44:52.754	2026-07-14 13:02:10.868	cmrknung7017n4hleej9wufua	HIGH_COPY
cmrknuxfj04tn4hle92yz8bc1	cmrknut0y039h4hlekczcvqvm	\N	SELL	2800000	2026-06-30 13:44:52.754	2026-07-14 13:02:10.879	cmrknung7017n4hleej9wufua	COPY
cmrknuxfv04tr4hlefsos8lqv	cmrknut0y039h4hlekczcvqvm	\N	SELL	14800000	2026-06-30 13:45:50.93	2026-07-14 13:02:10.891	cmrknul2k00f94hle8edpqejf	ORIGINAL
cmrknuxg704tv4hle4a11avp8	cmrknut0y039h4hlekczcvqvm	\N	SELL	12400000	2026-06-30 13:45:50.93	2026-07-14 13:02:10.903	cmrknul2k00f94hle8edpqejf	HIGH_COPY
cmrknuxgj04tz4hlernly7gaq	cmrknut0y039h4hlekczcvqvm	\N	SELL	2700000	2026-06-30 13:45:50.93	2026-07-14 13:02:10.915	cmrknul2k00f94hle8edpqejf	COPY
cmrknuxgv04u34hleq7nelujo	cmrknut0y039h4hlekczcvqvm	\N	SELL	14900000	2026-06-30 13:46:44.87	2026-07-14 13:02:10.928	cmrknuqa802fb4hlecn2zu5rr	ORIGINAL
cmrknuxh704u74hle14z5sfac	cmrknut0y039h4hlekczcvqvm	\N	SELL	12600000	2026-06-30 13:46:44.87	2026-07-14 13:02:10.939	cmrknuqa802fb4hlecn2zu5rr	HIGH_COPY
cmrknuxhi04ub4hlebngj4wcj	cmrknut0y039h4hlekczcvqvm	\N	SELL	3500000	2026-06-30 13:46:44.87	2026-07-14 13:02:10.95	cmrknuqa802fb4hlecn2zu5rr	COPY
cmrknuxht04uf4hle5x6js2s4	cmrknut0y039h4hlekczcvqvm	\N	SELL	14900000	2026-06-30 13:47:31.539	2026-07-14 13:02:10.962	cmrknuouh01vp4hle8wxziphl	ORIGINAL
cmrknuxi404uj4hle1erlofse	cmrknut0y039h4hlekczcvqvm	\N	SELL	12300000	2026-06-30 13:47:31.539	2026-07-14 13:02:10.973	cmrknuouh01vp4hle8wxziphl	HIGH_COPY
cmrknuxig04un4hleigo6pi49	cmrknut0y039h4hlekczcvqvm	\N	SELL	2700000	2026-06-30 13:47:31.539	2026-07-14 13:02:10.984	cmrknuouh01vp4hle8wxziphl	COPY
cmrknuxir04ur4hlerutvxf33	cmrknut0y039h4hlekczcvqvm	\N	SELL	10950000	2026-06-30 13:48:34.581	2026-07-14 13:02:10.995	cmrknuo9h01gv4hlexo1t13ns	ORIGINAL
cmrknuxj304uv4hlep5f58cnn	cmrknut0y039h4hlekczcvqvm	\N	SELL	8500000	2026-06-30 13:48:34.581	2026-07-14 13:02:11.007	cmrknuo9h01gv4hlexo1t13ns	HIGH_COPY
cmrknuxjf04uz4hle3xzlh6im	cmrknut0y039h4hlekczcvqvm	\N	SELL	3000000	2026-06-30 13:48:34.581	2026-07-14 13:02:11.019	cmrknuo9h01gv4hlexo1t13ns	COPY
cmrknuxjq04v34hlelnm23ks0	cmrknut0y039h4hlekczcvqvm	\N	SELL	15200000	2026-06-30 13:53:24.497	2026-07-14 13:02:11.03	cmrknumj200xz4hle4fc7tcqd	ORIGINAL
cmrknuxk204v74hle6sda2nwg	cmrknut0y039h4hlekczcvqvm	\N	SELL	12750000	2026-06-30 13:53:24.497	2026-07-14 13:02:11.042	cmrknumj200xz4hle4fc7tcqd	HIGH_COPY
cmrknuxkd04vb4hle5xlx9yzu	cmrknut0y039h4hlekczcvqvm	\N	SELL	2800000	2026-06-30 13:53:24.497	2026-07-14 13:02:11.053	cmrknumj200xz4hle4fc7tcqd	COPY
cmrknuxko04vf4hlep4uz4xwt	cmrknut0y039h4hlekczcvqvm	\N	SELL	15980000	2026-06-30 13:55:59.21	2026-07-14 13:02:11.065	cmrknusw103834hle28m0hv9t	ORIGINAL
cmrknuxkz04vj4hlej8xsudhj	cmrknut0y039h4hlekczcvqvm	\N	SELL	13400000	2026-06-30 13:55:59.21	2026-07-14 13:02:11.076	cmrknusw103834hle28m0hv9t	HIGH_COPY
cmrknuxld04vn4hlex13wtuho	cmrknut0y039h4hlekczcvqvm	\N	SELL	3200000	2026-06-30 13:55:59.21	2026-07-14 13:02:11.089	cmrknusw103834hle28m0hv9t	COPY
cmrknuxlo04vr4hleu7kt8tp8	cmrknut0y039h4hlekczcvqvm	\N	SELL	11350000	2026-06-30 13:57:11.552	2026-07-14 13:02:11.101	cmrknunpn01aj4hlec9uqf21n	ORIGINAL
cmrknuxm004vv4hle9gc5d0o5	cmrknut0y039h4hlekczcvqvm	\N	SELL	9850000	2026-06-30 13:57:11.552	2026-07-14 13:02:11.112	cmrknunpn01aj4hlec9uqf21n	HIGH_COPY
cmrknuxme04vz4hlezjwbggbd	cmrknut0y039h4hlekczcvqvm	\N	SELL	7600000	2026-06-30 13:57:11.552	2026-07-14 13:02:11.126	cmrknunpn01aj4hlec9uqf21n	COPY
cmrknuxmo04w34hle9omtg452	cmrknut0y039h4hlekczcvqvm	\N	SELL	4300000	2026-06-30 13:57:50.539	2026-07-14 13:02:11.137	cmrknural02q14hle9vr5m5o9	ORIGINAL
cmrknuxmy04w74hlelqh1wx7o	cmrknut0y039h4hlekczcvqvm	\N	SELL	2950000	2026-06-30 13:57:50.539	2026-07-14 13:02:11.146	cmrknural02q14hle9vr5m5o9	HIGH_COPY
cmrknuxn904wb4hleu36vpcwj	cmrknut0y039h4hlekczcvqvm	\N	SELL	1800000	2026-06-30 13:57:50.539	2026-07-14 13:02:11.157	cmrknural02q14hle9vr5m5o9	COPY
cmrknuxnk04wf4hlevoinmuok	cmrknut0y039h4hlekczcvqvm	\N	SELL	3500000	2026-06-30 13:58:44.931	2026-07-14 13:02:11.168	cmrknuor001t14hle6pm0e1ec	ORIGINAL
cmrknuxnu04wj4hlexp371ua5	cmrknut0y039h4hlekczcvqvm	\N	SELL	2550000	2026-06-30 13:58:44.931	2026-07-14 13:02:11.179	cmrknuor001t14hle6pm0e1ec	HIGH_COPY
cmrknuxo504wn4hleliwvjyzu	cmrknut0y039h4hlekczcvqvm	\N	SELL	1700000	2026-06-30 13:58:44.931	2026-07-14 13:02:11.189	cmrknuor001t14hle6pm0e1ec	COPY
cmrknuxog04wr4hlewoph03gm	cmrknut0y039h4hlekczcvqvm	\N	SELL	3950000	2026-06-30 13:59:34.491	2026-07-14 13:02:11.2	cmrknukir009r4hlewgnx0n0z	ORIGINAL
cmrknuxoq04wv4hlej9mm3elx	cmrknut0y039h4hlekczcvqvm	\N	SELL	2800000	2026-06-30 13:59:34.491	2026-07-14 13:02:11.211	cmrknukir009r4hlewgnx0n0z	HIGH_COPY
cmrknuxp104wz4hlegbw4hab1	cmrknut0y039h4hlekczcvqvm	\N	SELL	1700000	2026-06-30 13:59:34.491	2026-07-14 13:02:11.221	cmrknukir009r4hlewgnx0n0z	COPY
cmrknuxpb04x34hle43od6snc	cmrknut0y039h4hlekczcvqvm	\N	SELL	13400000	2026-06-30 14:00:57.535	2026-07-14 13:02:11.231	cmrknus1v02z14hleh3ioyxxq	ORIGINAL
cmrknuxpm04x74hlez4mxqps7	cmrknut0y039h4hlekczcvqvm	\N	SELL	11350000	2026-06-30 14:00:57.535	2026-07-14 13:02:11.242	cmrknus1v02z14hleh3ioyxxq	HIGH_COPY
cmrknuxpy04xb4hleg8v5m2c2	cmrknut0y039h4hlekczcvqvm	\N	SELL	3400000	2026-06-30 14:00:57.535	2026-07-14 13:02:11.254	cmrknus1v02z14hleh3ioyxxq	COPY
cmrknuxq904xf4hlekwzlulkv	cmrknut0y039h4hlekczcvqvm	\N	SELL	11900000	2026-06-30 14:10:36.887	2026-07-14 13:02:11.266	cmrknuoza01zn4hleklwdx8ju	ORIGINAL
cmrknuxql04xj4hlezv2eag8u	cmrknut0y039h4hlekczcvqvm	\N	SELL	9550000	2026-06-30 14:10:36.887	2026-07-14 13:02:11.277	cmrknuoza01zn4hleklwdx8ju	HIGH_COPY
cmrknuxqw04xn4hlewaoxeadj	cmrknut0y039h4hlekczcvqvm	\N	SELL	3600000	2026-06-30 14:10:36.887	2026-07-14 13:02:11.289	cmrknuoza01zn4hleklwdx8ju	COPY
cmrknuxr804xr4hle5bdkhdsa	cmrknut0y039h4hlekczcvqvm	\N	SELL	14950000	2026-06-30 14:11:13.317	2026-07-14 13:02:11.3	cmrknupj9027t4hle7p7wpqj7	ORIGINAL
cmrknuxrk04xv4hle6lfybbz8	cmrknut0y039h4hlekczcvqvm	\N	SELL	12300000	2026-06-30 14:11:13.317	2026-07-14 13:02:11.312	cmrknupj9027t4hle7p7wpqj7	HIGH_COPY
cmrknuxrv04xz4hlen4dzmn6i	cmrknut0y039h4hlekczcvqvm	\N	SELL	9700000	2026-06-30 14:11:13.317	2026-07-14 13:02:11.323	cmrknupj9027t4hle7p7wpqj7	COPY
cmrknuxs904y34hlesoq9fjt9	cmrknut0y039h4hlekczcvqvm	\N	SELL	11300000	2026-06-30 14:12:08.632	2026-07-14 13:02:11.337	cmrknuovy01x54hlezhihgvxx	ORIGINAL
cmrknuxsl04y74hle02wkt21h	cmrknut0y039h4hlekczcvqvm	\N	SELL	7800000	2026-06-30 14:12:08.632	2026-07-14 13:02:11.349	cmrknuovy01x54hlezhihgvxx	HIGH_COPY
cmrknuxsy04yb4hle3lfh6hma	cmrknut0y039h4hlekczcvqvm	\N	SELL	2900000	2026-06-30 14:12:08.632	2026-07-14 13:02:11.362	cmrknuovy01x54hlezhihgvxx	COPY
cmrknuxt904yf4hleyxe6zhri	cmrknut0y039h4hlekczcvqvm	\N	SELL	9800000	2026-06-30 14:15:10.624	2026-07-14 13:02:11.373	cmrknusw803854hlertklbqpd	ORIGINAL
cmrknuxtl04yj4hlet7j01nv7	cmrknut0y039h4hlekczcvqvm	\N	SELL	7400000	2026-06-30 14:15:10.624	2026-07-14 13:02:11.385	cmrknusw803854hlertklbqpd	HIGH_COPY
cmrknuxtx04yn4hlejczgxl24	cmrknut0y039h4hlekczcvqvm	\N	SELL	2900000	2026-06-30 14:15:10.624	2026-07-14 13:02:11.397	cmrknusw803854hlertklbqpd	COPY
cmrknuxu904yr4hle5ogyquqe	cmrknut0y039h4hlekczcvqvm	\N	SELL	3450000	2026-06-30 14:17:00.566	2026-07-14 13:02:11.409	cmrknus3x02zn4hle9485qdhb	ORIGINAL
cmrknuxul04yv4hle4596a28r	cmrknut0y039h4hlekczcvqvm	\N	SELL	2200000	2026-06-30 14:17:00.566	2026-07-14 13:02:11.421	cmrknus3x02zn4hle9485qdhb	HIGH_COPY
cmrknuxuz04yz4hleuwer4k20	cmrknut0y039h4hlekczcvqvm	\N	SELL	1600000	2026-06-30 14:17:00.566	2026-07-14 13:02:11.436	cmrknus3x02zn4hle9485qdhb	COPY
cmrknuxvc04z34hlehenc4zpf	cmrknut0y039h4hlekczcvqvm	\N	SELL	13800000	2026-06-30 14:19:06.372	2026-07-14 13:02:11.448	cmrknusd0032f4hlen5oyzfzd	ORIGINAL
cmrknuxvo04z74hlerelsirdj	cmrknut0y039h4hlekczcvqvm	\N	SELL	10500000	2026-06-30 14:19:06.372	2026-07-14 13:02:11.46	cmrknusd0032f4hlen5oyzfzd	HIGH_COPY
cmrknuxw004zb4hlei8trkwxd	cmrknut0y039h4hlekczcvqvm	\N	SELL	2700000	2026-06-30 14:19:06.372	2026-07-14 13:02:11.472	cmrknusd0032f4hlen5oyzfzd	COPY
cmrknuxwc04zf4hleaxsp6f7k	cmrknut0y039h4hlekczcvqvm	\N	SELL	14700000	2026-06-30 14:22:34.15	2026-07-14 13:02:11.485	cmrknuoq001s94hleyl59xkq5	ORIGINAL
cmrknuxwr04zj4hleddsymoxc	cmrknut0y039h4hlekczcvqvm	\N	SELL	10950000	2026-06-30 14:22:34.15	2026-07-14 13:02:11.499	cmrknuoq001s94hleyl59xkq5	HIGH_COPY
cmrknuxx304zn4hlebhy88gqq	cmrknut0y039h4hlekczcvqvm	\N	SELL	2800000	2026-06-30 14:22:34.15	2026-07-14 13:02:11.511	cmrknuoq001s94hleyl59xkq5	COPY
cmrknuxxg04zr4hlexuecxn28	cmrknut0y039h4hlekczcvqvm	\N	SELL	14850000	2026-06-30 14:23:13.172	2026-07-14 13:02:11.525	cmrknulmp00pp4hlet3hpl7rg	ORIGINAL
cmrknuxxt04zv4hlekb69afhl	cmrknut0y039h4hlekczcvqvm	\N	SELL	12300000	2026-06-30 14:23:13.172	2026-07-14 13:02:11.537	cmrknulmp00pp4hlet3hpl7rg	HIGH_COPY
cmrknuxy804zz4hleh7ua6v6v	cmrknut0y039h4hlekczcvqvm	\N	SELL	3300000	2026-06-30 14:23:13.172	2026-07-14 13:02:11.552	cmrknulmp00pp4hlet3hpl7rg	COPY
cmrknuxyl05034hleezp30u2m	cmrknut0y039h4hlekczcvqvm	\N	SELL	3550000	2026-06-30 14:24:06.117	2026-07-14 13:02:11.565	cmrknurrb02vz4hlev0qzd26z	ORIGINAL
cmrknuxyw05074hlezxg4esh2	cmrknut0y039h4hlekczcvqvm	\N	SELL	2500000	2026-06-30 14:24:06.117	2026-07-14 13:02:11.576	cmrknurrb02vz4hlev0qzd26z	HIGH_COPY
cmrknuxz8050b4hlemysj2ya7	cmrknut0y039h4hlekczcvqvm	\N	SELL	1900000	2026-06-30 14:24:06.117	2026-07-14 13:02:11.588	cmrknurrb02vz4hlev0qzd26z	COPY
cmrknuxzk050f4hlef5tkeg5q	cmrknut0y039h4hlekczcvqvm	\N	SELL	3550000	2026-06-30 14:24:48.352	2026-07-14 13:02:11.601	cmrknusk3034j4hle92gl94ax	ORIGINAL
cmrknuxzw050j4hle4sanoif8	cmrknut0y039h4hlekczcvqvm	\N	SELL	2500000	2026-06-30 14:24:48.352	2026-07-14 13:02:11.612	cmrknusk3034j4hle92gl94ax	HIGH_COPY
cmrknuy07050n4hlebz05utzn	cmrknut0y039h4hlekczcvqvm	\N	SELL	1900000	2026-06-30 14:24:48.352	2026-07-14 13:02:11.624	cmrknusk3034j4hle92gl94ax	COPY
cmrknuy0k050r4hleryxogrxz	cmrknut0y039h4hlekczcvqvm	\N	SELL	3900000	2026-06-30 14:25:40.445	2026-07-14 13:02:11.636	cmrknuq5z02e34hlejp111l5i	ORIGINAL
cmrknuy0v050v4hlez65kncl4	cmrknut0y039h4hlekczcvqvm	\N	SELL	2750000	2026-06-30 14:25:40.445	2026-07-14 13:02:11.648	cmrknuq5z02e34hlejp111l5i	HIGH_COPY
cmrknuy17050z4hlebcsk8na4	cmrknut0y039h4hlekczcvqvm	\N	SELL	1800000	2026-06-30 14:25:40.445	2026-07-14 13:02:11.659	cmrknuq5z02e34hlejp111l5i	COPY
cmrknuy1i05134hleb6f5jy9f	cmrknut0y039h4hlekczcvqvm	\N	SELL	14900000	2026-06-30 14:26:33.168	2026-07-14 13:02:11.671	cmrknurtf02wl4hle9qhocufy	ORIGINAL
cmrknuy1t05174hlenr0xstp6	cmrknut0y039h4hlekczcvqvm	\N	SELL	12500000	2026-06-30 14:26:33.168	2026-07-14 13:02:11.682	cmrknurtf02wl4hle9qhocufy	HIGH_COPY
cmrknuy23051b4hleb4v6a2xe	cmrknut0y039h4hlekczcvqvm	\N	SELL	2800000	2026-06-30 14:26:33.168	2026-07-14 13:02:11.692	cmrknurtf02wl4hle9qhocufy	COPY
cmrknuy2f051f4hlek9l3i88u	cmrknut0y039h4hlekczcvqvm	\N	SELL	10950000	2026-06-30 14:27:19.188	2026-07-14 13:02:11.704	cmrknup0o020t4hle1ydhrjrc	ORIGINAL
cmrknuy2r051j4hlerssxgzqx	cmrknut0y039h4hlekczcvqvm	\N	SELL	8800000	2026-06-30 14:27:19.188	2026-07-14 13:02:11.715	cmrknup0o020t4hle1ydhrjrc	HIGH_COPY
cmrknuy32051n4hlekod62dr3	cmrknut0y039h4hlekczcvqvm	\N	SELL	3100000	2026-06-30 14:27:19.188	2026-07-14 13:02:11.726	cmrknup0o020t4hle1ydhrjrc	COPY
cmrknuy3d051r4hle3icxfjgc	cmrknut0y039h4hlekczcvqvm	\N	SELL	10950000	2026-06-30 14:28:08.402	2026-07-14 13:02:11.737	cmrknum4400u94hle5h0g3m8t	ORIGINAL
cmrknuy3p051v4hlezuto3zt4	cmrknut0y039h4hlekczcvqvm	\N	SELL	8400000	2026-06-30 14:28:08.402	2026-07-14 13:02:11.749	cmrknum4400u94hle5h0g3m8t	HIGH_COPY
cmrknuy40051z4hleco0y9x3e	cmrknut0y039h4hlekczcvqvm	\N	SELL	3300000	2026-06-30 14:28:08.402	2026-07-14 13:02:11.76	cmrknum4400u94hle5h0g3m8t	COPY
cmrknuy4b05234hle7onxuav6	cmrknut0y039h4hlekczcvqvm	\N	SELL	26000000	2026-07-01 07:15:56.949	2026-07-14 13:02:11.772	cmrknumg700x94hle12jr1qh3	ORIGINAL
cmrknuy4n05274hleynfk2hdh	cmrknut0y039h4hlekczcvqvm	\N	SELL	23500000	2026-07-01 07:15:56.949	2026-07-14 13:02:11.783	cmrknumg700x94hle12jr1qh3	HIGH_COPY
cmrknuy4z052b4hleemktxt85	cmrknut0y039h4hlekczcvqvm	\N	SELL	19000000	2026-07-01 07:15:56.949	2026-07-14 13:02:11.795	cmrknumg700x94hle12jr1qh3	COPY
cmrknuy5a052f4hlegofw90nr	cmrknut0y039h4hlekczcvqvm	\N	SELL	14950000	2026-07-01 07:17:39.025	2026-07-14 13:02:11.806	cmrknurv002x14hlely1ge704	ORIGINAL
cmrknuy5m052j4hleogqoci3y	cmrknut0y039h4hlekczcvqvm	\N	SELL	12500000	2026-07-01 07:17:39.025	2026-07-14 13:02:11.818	cmrknurv002x14hlely1ge704	HIGH_COPY
cmrknuy5w052n4hleq4wtpnhu	cmrknut0y039h4hlekczcvqvm	\N	SELL	5400000	2026-07-01 07:17:39.025	2026-07-14 13:02:11.828	cmrknurv002x14hlely1ge704	COPY
cmrknuy66052r4hle9n43ux05	cmrkbbzjk000amneoowf62wmn	\N	SELL	4200000	2026-07-01 07:24:39.092	2026-07-14 13:02:11.839	cmrknusvh037x4hleu56m0lj2	ORIGINAL
cmrknuy6i052v4hlec3lelocl	cmrkbbzjk000amneoowf62wmn	\N	SELL	3100000	2026-07-01 07:24:39.092	2026-07-14 13:02:11.85	cmrknusvh037x4hleu56m0lj2	HIGH_COPY
cmrknuy6u052z4hle5b1hsr8j	cmrkbbzjk000amneoowf62wmn	\N	SELL	1900000	2026-07-01 07:24:39.092	2026-07-14 13:02:11.862	cmrknusvh037x4hleu56m0lj2	COPY
cmrknuy7405334hle4nlr8ai0	cmrknut0y039h4hlekczcvqvm	\N	SELL	16600000	2026-07-01 07:26:05.249	2026-07-14 13:02:11.873	cmrknukuj00d34hleke6opuzt	ORIGINAL
cmrknuy7g05374hleo0mgmuno	cmrknut0y039h4hlekczcvqvm	\N	SELL	14800000	2026-07-01 07:26:05.249	2026-07-14 13:02:11.884	cmrknukuj00d34hleke6opuzt	HIGH_COPY
cmrknuy7r053b4hle709wqkgm	cmrknut0y039h4hlekczcvqvm	\N	SELL	12000000	2026-07-01 07:26:05.249	2026-07-14 13:02:11.895	cmrknukuj00d34hleke6opuzt	COPY
cmrknuy83053f4hleyzj4hcmb	cmrkbbzjk000amneoowf62wmn	\N	SELL	2200000	2026-07-01 07:36:00.938	2026-07-14 13:02:11.907	cmrknusmh03574hleaoy1wipc	ORIGINAL
cmrknuy8f053j4hlecey3w8fe	cmrkbbzjk000amneoowf62wmn	\N	SELL	1600000	2026-07-01 07:36:00.938	2026-07-14 13:02:11.919	cmrknusmh03574hleaoy1wipc	HIGH_COPY
cmrknuy8s053n4hle60cre3i2	cmrkbbzjk000amneoowf62wmn	\N	SELL	900000	2026-07-01 07:36:00.938	2026-07-14 13:02:11.932	cmrknusmh03574hleaoy1wipc	COPY
cmrknuy93053r4hlecgd2clr1	cmrkbbzjk000amneoowf62wmn	\N	SELL	2300000	2026-07-01 07:36:50.243	2026-07-14 13:02:11.943	cmrknusmp03594hleu7is34yw	ORIGINAL
cmrknuy9e053v4hlemp7h5i7g	cmrkbbzjk000amneoowf62wmn	\N	SELL	1700000	2026-07-01 07:36:50.243	2026-07-14 13:02:11.955	cmrknusmp03594hleu7is34yw	HIGH_COPY
cmrknuy9q053z4hled244eyki	cmrkbbzjk000amneoowf62wmn	\N	SELL	900000	2026-07-01 07:36:50.243	2026-07-14 13:02:11.966	cmrknusmp03594hleu7is34yw	COPY
cmrknuya005434hlepym5qz8o	cmrkbbzjk000amneoowf62wmn	\N	SELL	2600000	2026-07-01 07:37:24.958	2026-07-14 13:02:11.977	cmrknusmw035b4hletixi9cgt	ORIGINAL
cmrknuyac05474hlen5w25ker	cmrkbbzjk000amneoowf62wmn	\N	SELL	1700000	2026-07-01 07:37:24.958	2026-07-14 13:02:11.988	cmrknusmw035b4hletixi9cgt	HIGH_COPY
cmrknuyao054b4hlez2osa4o9	cmrkbbzjk000amneoowf62wmn	\N	SELL	900000	2026-07-01 07:37:24.958	2026-07-14 13:02:12	cmrknusmw035b4hletixi9cgt	COPY
cmrknuyb0054f4hletwk33824	cmrkbbzjk000amneoowf62wmn	\N	SELL	2800000	2026-07-01 07:37:58.918	2026-07-14 13:02:12.012	cmrknusn2035d4hlet253fmsf	ORIGINAL
cmrknuybc054j4hleepg6trdt	cmrkbbzjk000amneoowf62wmn	\N	SELL	1900000	2026-07-01 07:37:58.918	2026-07-14 13:02:12.024	cmrknusn2035d4hlet253fmsf	HIGH_COPY
cmrknuybn054n4hlesv7cu8el	cmrkbbzjk000amneoowf62wmn	\N	SELL	1300000	2026-07-01 07:37:58.918	2026-07-14 13:02:12.036	cmrknusn2035d4hlet253fmsf	COPY
cmrknuybz054r4hle3vw3v09t	cmrkbbzjk000amneoowf62wmn	\N	SELL	3400000	2026-07-01 07:38:34.258	2026-07-14 13:02:12.047	cmrknusnf035h4hleqjp3o4de	ORIGINAL
cmrknuyca054v4hle6mjck9yn	cmrkbbzjk000amneoowf62wmn	\N	SELL	2300000	2026-07-01 07:38:34.258	2026-07-14 13:02:12.058	cmrknusnf035h4hleqjp3o4de	HIGH_COPY
cmrknuycm054z4hlephsu2oo8	cmrkbbzjk000amneoowf62wmn	\N	SELL	1400000	2026-07-01 07:38:34.258	2026-07-14 13:02:12.071	cmrknusnf035h4hleqjp3o4de	COPY
cmrknuycy05534hle8l6b0ye9	cmrkbbzjk000amneoowf62wmn	\N	SELL	2100000	2026-07-01 07:39:10.239	2026-07-14 13:02:12.082	cmrknusnn035j4hlemqflbimg	ORIGINAL
cmrknuyd905574hle7n7zap65	cmrkbbzjk000amneoowf62wmn	\N	SELL	1500000	2026-07-01 07:39:10.239	2026-07-14 13:02:12.093	cmrknusnn035j4hlemqflbimg	HIGH_COPY
cmrknuydk055b4hlezz1021kq	cmrkbbzjk000amneoowf62wmn	\N	SELL	800000	2026-07-01 07:39:10.239	2026-07-14 13:02:12.104	cmrknusnn035j4hlemqflbimg	COPY
cmrknuydw055f4hlef1hf6arl	cmrkbbzjk000amneoowf62wmn	\N	SELL	2500000	2026-07-01 07:39:38.378	2026-07-14 13:02:12.116	cmrknusnt035l4hle78ull8hq	ORIGINAL
cmrknuye7055j4hlek7325xlt	cmrkbbzjk000amneoowf62wmn	\N	SELL	1700000	2026-07-01 07:39:38.378	2026-07-14 13:02:12.127	cmrknusnt035l4hle78ull8hq	HIGH_COPY
cmrknuyei055n4hlejzf2sahq	cmrkbbzjk000amneoowf62wmn	\N	SELL	1100000	2026-07-01 07:39:38.378	2026-07-14 13:02:12.138	cmrknusnt035l4hle78ull8hq	COPY
cmrknuyeu055r4hlemaa1ojsb	cmrkbbzjk000amneoowf62wmn	\N	SELL	3500000	2026-07-01 07:40:22.673	2026-07-14 13:02:12.15	cmrknuso6035p4hleg1f5s7qh	ORIGINAL
cmrknuyf6055v4hlebky1njsp	cmrkbbzjk000amneoowf62wmn	\N	SELL	2700000	2026-07-01 07:40:22.673	2026-07-14 13:02:12.162	cmrknuso6035p4hleg1f5s7qh	HIGH_COPY
cmrknuyfh055z4hlesr7mepjv	cmrkbbzjk000amneoowf62wmn	\N	SELL	1900000	2026-07-01 07:40:22.673	2026-07-14 13:02:12.174	cmrknuso6035p4hleg1f5s7qh	COPY
cmrknuyfs05634hledpkpy0tj	cmrkbbzjk000amneoowf62wmn	\N	SELL	3500000	2026-07-01 07:41:00.763	2026-07-14 13:02:12.184	cmrknusoj035t4hleeogpfz30	ORIGINAL
cmrknuyg305674hlea6ozoixf	cmrkbbzjk000amneoowf62wmn	\N	SELL	2700000	2026-07-01 07:41:00.763	2026-07-14 13:02:12.195	cmrknusoj035t4hleeogpfz30	HIGH_COPY
cmrknuygg056b4hledbgdjn5s	cmrkbbzjk000amneoowf62wmn	\N	SELL	1600000	2026-07-01 07:41:00.763	2026-07-14 13:02:12.208	cmrknusoj035t4hleeogpfz30	COPY
cmrknuygr056f4hle1tgw4jt9	cmrkbbzjk000amneoowf62wmn	\N	SELL	4100000	2026-07-01 07:42:38	2026-07-14 13:02:12.219	cmrknuswf03874hlem6077xbd	ORIGINAL
cmrknuyh1056j4hlea50up5im	cmrkbbzjk000amneoowf62wmn	\N	SELL	3000000	2026-07-01 07:42:38	2026-07-14 13:02:12.229	cmrknuswf03874hlem6077xbd	HIGH_COPY
cmrknuyhb056n4hlevyrk8mx7	cmrkbbzjk000amneoowf62wmn	\N	SELL	2100000	2026-07-01 07:42:38	2026-07-14 13:02:12.24	cmrknuswf03874hlem6077xbd	COPY
cmrknuyhm056r4hleouj7no3g	cmrkbbzjk000amneoowf62wmn	\N	SELL	3200000	2026-07-01 07:43:15.813	2026-07-14 13:02:12.251	cmrknusop035v4hley486zzxx	ORIGINAL
cmrknuyhx056v4hle3mxrppr1	cmrkbbzjk000amneoowf62wmn	\N	SELL	2400000	2026-07-01 07:43:15.813	2026-07-14 13:02:12.261	cmrknusop035v4hley486zzxx	HIGH_COPY
cmrknuyi8056z4hle7rudtbfa	cmrkbbzjk000amneoowf62wmn	\N	SELL	1700000	2026-07-01 07:43:15.813	2026-07-14 13:02:12.273	cmrknusop035v4hley486zzxx	COPY
cmrknuyij05734hlephxnrps7	cmrkbbzjk000amneoowf62wmn	\N	SELL	3800000	2026-07-01 07:46:19.168	2026-07-14 13:02:12.284	cmrknuswm03894hle861luy2i	ORIGINAL
cmrknuyiv05774hles7efszb3	cmrkbbzjk000amneoowf62wmn	\N	SELL	2800000	2026-07-01 07:46:19.168	2026-07-14 13:02:12.295	cmrknuswm03894hle861luy2i	HIGH_COPY
cmrknuyj7057b4hleqe86g2or	cmrkbbzjk000amneoowf62wmn	\N	SELL	1800000	2026-07-01 07:46:19.168	2026-07-14 13:02:12.307	cmrknuswm03894hle861luy2i	COPY
cmrknuyjj057f4hle874zfg14	cmrkbbzjk000amneoowf62wmn	\N	SELL	4300000	2026-07-01 07:47:03.637	2026-07-14 13:02:12.319	cmrknusm403534hleg0ak87ub	ORIGINAL
cmrknuyju057j4hleaheba9uu	cmrkbbzjk000amneoowf62wmn	\N	SELL	3200000	2026-07-01 07:47:03.637	2026-07-14 13:02:12.33	cmrknusm403534hleg0ak87ub	HIGH_COPY
cmrknuyk5057n4hlea9soku82	cmrkbbzjk000amneoowf62wmn	\N	SELL	2500000	2026-07-01 07:47:03.637	2026-07-14 13:02:12.342	cmrknusm403534hleg0ak87ub	COPY
cmrknuykh057r4hleqrzxyxt6	cmrkbbzjk000amneoowf62wmn	\N	SELL	5900000	2026-07-01 07:47:33.556	2026-07-14 13:02:12.353	cmrknuswu038b4hleatfopbt3	ORIGINAL
cmrknuyks057v4hleye4jpwml	cmrkbbzjk000amneoowf62wmn	\N	SELL	4700000	2026-07-01 07:47:33.556	2026-07-14 13:02:12.364	cmrknuswu038b4hleatfopbt3	HIGH_COPY
cmrknuyl3057z4hle3e0e15bb	cmrkbbzjk000amneoowf62wmn	\N	SELL	3500000	2026-07-01 07:47:33.556	2026-07-14 13:02:12.375	cmrknuswu038b4hleatfopbt3	COPY
cmrknuyle05834hleoip1p10f	cmrkbbzjk000amneoowf62wmn	\N	SELL	2100000	2026-07-01 07:57:23.533	2026-07-14 13:02:12.387	cmrknusr0036l4hleezwyyicq	ORIGINAL
cmrknuylp05874hle15z2kduw	cmrkbbzjk000amneoowf62wmn	\N	SELL	1600000	2026-07-01 07:57:23.533	2026-07-14 13:02:12.397	cmrknusr0036l4hleezwyyicq	HIGH_COPY
cmrknuym1058b4hle7ss7mbln	cmrkbbzjk000amneoowf62wmn	\N	SELL	1000000	2026-07-01 07:57:23.533	2026-07-14 13:02:12.409	cmrknusr0036l4hleezwyyicq	COPY
cmrknuymc058f4hlebnyb6amq	cmrkbbzjk000amneoowf62wmn	\N	SELL	1400000	2026-07-01 07:58:00.418	2026-07-14 13:02:12.42	cmrknusxr038l4hlewlqsay4j	ORIGINAL
cmrknuymn058j4hleoqdftbjl	cmrkbbzjk000amneoowf62wmn	\N	SELL	900000	2026-07-01 07:58:00.418	2026-07-14 13:02:12.431	cmrknusxr038l4hlewlqsay4j	HIGH_COPY
cmrknuymy058n4hlecjwvuuc6	cmrkbbzjk000amneoowf62wmn	\N	SELL	500000	2026-07-01 07:58:00.418	2026-07-14 13:02:12.442	cmrknusxr038l4hlewlqsay4j	COPY
cmrknuyn9058r4hleue3tmz3e	cmrkbbzjk000amneoowf62wmn	\N	SELL	3200000	2026-07-01 07:59:04.289	2026-07-14 13:02:12.453	cmrknusxk038j4hle6jj6osi9	ORIGINAL
cmrknuynk058v4hle6i2ep69v	cmrkbbzjk000amneoowf62wmn	\N	SELL	2100000	2026-07-01 07:59:04.289	2026-07-14 13:02:12.464	cmrknusxk038j4hle6jj6osi9	HIGH_COPY
cmrknuynu058z4hleg7xylnuh	cmrkbbzjk000amneoowf62wmn	\N	SELL	1300000	2026-07-01 07:59:04.289	2026-07-14 13:02:12.474	cmrknusxk038j4hle6jj6osi9	COPY
cmrknuyo505934hle9wnkxb50	cmrkbbzjk000amneoowf62wmn	\N	SELL	2400000	2026-07-01 07:59:58.486	2026-07-14 13:02:12.486	cmrknusxe038h4hle4ta0f80o	ORIGINAL
cmrknuyoh05974hleifi5smm8	cmrkbbzjk000amneoowf62wmn	\N	SELL	1500000	2026-07-01 07:59:58.486	2026-07-14 13:02:12.497	cmrknusxe038h4hle4ta0f80o	HIGH_COPY
cmrknuyos059b4hlezogx9vb1	cmrkbbzjk000amneoowf62wmn	\N	SELL	900000	2026-07-01 07:59:58.486	2026-07-14 13:02:12.508	cmrknusxe038h4hle4ta0f80o	COPY
cmrknuyp4059f4hle016rdt35	cmrkbbzjk000amneoowf62wmn	\N	SELL	2400000	2026-07-01 08:00:34.118	2026-07-14 13:02:12.52	cmrknusx8038f4hleizavtaji	ORIGINAL
cmrknuypf059j4hlewm5w4q1h	cmrkbbzjk000amneoowf62wmn	\N	SELL	1500000	2026-07-01 08:00:34.118	2026-07-14 13:02:12.531	cmrknusx8038f4hleizavtaji	HIGH_COPY
cmrknuypq059n4hle2wfmz2kj	cmrkbbzjk000amneoowf62wmn	\N	SELL	900000	2026-07-01 08:00:34.118	2026-07-14 13:02:12.542	cmrknusx8038f4hleizavtaji	COPY
cmrknuyq2059r4hleoe4egiyw	cmrkbbzjk000amneoowf62wmn	\N	SELL	2000000	2026-07-01 08:00:59.042	2026-07-14 13:02:12.554	cmrknusx0038d4hleov6tmfby	ORIGINAL
cmrknuyqe059v4hlele3aoiup	cmrkbbzjk000amneoowf62wmn	\N	SELL	1500000	2026-07-01 08:00:59.042	2026-07-14 13:02:12.566	cmrknusx0038d4hleov6tmfby	HIGH_COPY
cmrknuyqo059z4hlegcje2sok	cmrkbbzjk000amneoowf62wmn	\N	SELL	900000	2026-07-01 08:00:59.042	2026-07-14 13:02:12.576	cmrknusx0038d4hleov6tmfby	COPY
cmrknuyqz05a34hle2ohbol9k	cmrkbbzjk000amneoowf62wmn	\N	SELL	2700000	2026-07-01 08:07:15.632	2026-07-14 13:02:12.588	cmrknusyb038r4hle088k0w40	ORIGINAL
cmrknuyrb05a74hlen0q53zvx	cmrkbbzjk000amneoowf62wmn	\N	SELL	1900000	2026-07-01 08:07:15.632	2026-07-14 13:02:12.599	cmrknusyb038r4hle088k0w40	HIGH_COPY
cmrknuyrm05ab4hleuvyjrgix	cmrkbbzjk000amneoowf62wmn	\N	SELL	1100000	2026-07-01 08:07:15.632	2026-07-14 13:02:12.61	cmrknusyb038r4hle088k0w40	COPY
cmrknuyrx05af4hlexwcugifx	cmrkbbzjk000amneoowf62wmn	\N	SELL	4500000	2026-07-01 08:08:30.963	2026-07-14 13:02:12.621	cmrknusy5038p4hle946qa1v3	ORIGINAL
cmrknuys905aj4hlepn491goh	cmrkbbzjk000amneoowf62wmn	\N	SELL	3400000	2026-07-01 08:08:30.963	2026-07-14 13:02:12.633	cmrknusy5038p4hle946qa1v3	HIGH_COPY
cmrknuysk05an4hlefnifjp0k	cmrkbbzjk000amneoowf62wmn	\N	SELL	2200000	2026-07-01 08:08:30.963	2026-07-14 13:02:12.644	cmrknusy5038p4hle946qa1v3	COPY
cmrknuysv05ar4hle6j3j79s7	cmrkbbzjk000amneoowf62wmn	\N	SELL	4500000	2026-07-01 08:10:46.069	2026-07-14 13:02:12.655	cmrknusyh038t4hlecmwekduf	ORIGINAL
cmrknuyt705av4hleb7voqwn0	cmrkbbzjk000amneoowf62wmn	\N	SELL	3600000	2026-07-01 08:10:46.069	2026-07-14 13:02:12.667	cmrknusyh038t4hlecmwekduf	HIGH_COPY
cmrknuytj05az4hlehsa7edqb	cmrkbbzjk000amneoowf62wmn	\N	SELL	2800000	2026-07-01 08:10:46.069	2026-07-14 13:02:12.679	cmrknusyh038t4hlecmwekduf	COPY
cmrknuyu205b34hleonv4jjqy	cmrkbbzjk000amneoowf62wmn	\N	SELL	4500000	2026-07-01 08:11:25.071	2026-07-14 13:02:12.697	cmrknusyo038v4hlesf7ff2hm	ORIGINAL
cmrknuyur05b74hleisdklv5w	cmrkbbzjk000amneoowf62wmn	\N	SELL	3300000	2026-07-01 08:11:25.071	2026-07-14 13:02:12.722	cmrknusyo038v4hlesf7ff2hm	HIGH_COPY
cmrknuyvs05bb4hlekm4v3p1x	cmrkbbzjk000amneoowf62wmn	\N	SELL	2500000	2026-07-01 08:11:25.071	2026-07-14 13:02:12.76	cmrknusyo038v4hlesf7ff2hm	COPY
cmrknuyx505bf4hle0g9fxt3u	cmrknut0y039h4hlekczcvqvm	\N	SELL	3950000	2026-07-01 09:39:48.843	2026-07-14 13:02:12.809	cmrknul5q00gl4hle3gl1cj9r	ORIGINAL
cmrknuyxr05bj4hlev5g010m4	cmrknut0y039h4hlekczcvqvm	\N	SELL	2850000	2026-07-01 09:39:48.843	2026-07-14 13:02:12.831	cmrknul5q00gl4hle3gl1cj9r	HIGH_COPY
cmrknuyy605bn4hletbed61jt	cmrknut0y039h4hlekczcvqvm	\N	SELL	1700000	2026-07-01 09:39:48.843	2026-07-14 13:02:12.846	cmrknul5q00gl4hle3gl1cj9r	COPY
cmrknuyyo05br4hle2a4o36d2	cmrknut0y039h4hlekczcvqvm	\N	SELL	3850000	2026-07-01 09:52:28.558	2026-07-14 13:02:12.864	cmrknukko00aj4hle515lwewj	ORIGINAL
cmrknuyz705bv4hle0oif19lo	cmrknut0y039h4hlekczcvqvm	\N	SELL	2350000	2026-07-01 09:52:28.558	2026-07-14 13:02:12.882	cmrknukko00aj4hle515lwewj	HIGH_COPY
cmrknuyzq05bz4hlevtl2wl6p	cmrknut0y039h4hlekczcvqvm	\N	SELL	1400000	2026-07-01 09:52:28.558	2026-07-14 13:02:12.902	cmrknukko00aj4hle515lwewj	COPY
cmrknuz0b05c34hle7vs7iipg	cmrkbbzjk000amneoowf62wmn	\N	SELL	2450000	2026-07-08 06:49:13.215	2026-07-14 13:02:12.923	cmrknushw033v4hletkgm2ouv	ORIGINAL
cmrknuz0s05c74hlefh5ky3sv	cmrkbbzjk000amneoowf62wmn	\N	SELL	1700000	2026-07-08 06:49:13.215	2026-07-14 13:02:12.94	cmrknushw033v4hletkgm2ouv	HIGH_COPY
cmrknuz1105cb4hleelvdex1c	cmrkbbzjk000amneoowf62wmn	\N	SELL	1200000	2026-07-08 06:49:13.215	2026-07-14 13:02:12.949	cmrknushw033v4hletkgm2ouv	COPY
cmrknuz1c05cf4hlezkmf18es	cmrknut0y039h4hlekczcvqvm	\N	SELL	5100000	2026-07-08 07:09:18.163	2026-07-14 13:02:12.96	cmrknul8c00i34hley56j21qf	ORIGINAL
cmrknuz1j05cj4hler6rx3a45	cmrknut0y039h4hlekczcvqvm	\N	SELL	3900000	2026-07-08 07:09:18.163	2026-07-14 13:02:12.968	cmrknul8c00i34hley56j21qf	HIGH_COPY
cmrknuz1r05cn4hleclkxuvtg	cmrknut0y039h4hlekczcvqvm	\N	SELL	3000000	2026-07-08 07:09:18.163	2026-07-14 13:02:12.976	cmrknul8c00i34hley56j21qf	COPY
cmrknuz1y05cr4hlecbac27e4	cmrkbbzjk000amneoowf62wmn	\N	SELL	4500000	2026-07-08 07:13:27.101	2026-07-14 13:02:12.983	cmrknusxy038n4hle157g9ifu	ORIGINAL
cmrknuz2905cv4hlevas8t4w8	cmrkbbzjk000amneoowf62wmn	\N	SELL	3450000	2026-07-08 07:13:27.101	2026-07-14 13:02:12.994	cmrknusxy038n4hle157g9ifu	HIGH_COPY
cmrknuz2j05cz4hlehnosbr67	cmrkbbzjk000amneoowf62wmn	\N	SELL	2500000	2026-07-08 07:13:27.101	2026-07-14 13:02:13.003	cmrknusxy038n4hle157g9ifu	COPY
cmrknuz2s05d34hlegadi69c5	cmrkbbzjk000amneoowf62wmn	\N	SELL	3500000	2026-07-08 07:29:23.77	2026-07-14 13:02:13.012	cmrknusc903274hle99wb20e9	ORIGINAL
cmrknuz3005d74hlep15jaazn	cmrkbbzjk000amneoowf62wmn	\N	SELL	2600000	2026-07-08 07:29:23.77	2026-07-14 13:02:13.02	cmrknusc903274hle99wb20e9	HIGH_COPY
cmrknuz3b05db4hleh3dumhc9	cmrkbbzjk000amneoowf62wmn	\N	SELL	1500000	2026-07-08 07:29:23.77	2026-07-14 13:02:13.031	cmrknusc903274hle99wb20e9	COPY
cmrknuz3j05df4hle257g2z9b	cmrknut0y039h4hlekczcvqvm	\N	SELL	14000000	2026-07-08 10:15:11.751	2026-07-14 13:02:13.039	cmrknusyu038x4hle19cwnvgc	ORIGINAL
cmrknuz3p05dj4hle4y6df2ce	cmrknut0y039h4hlekczcvqvm	\N	SELL	11000000	2026-07-08 10:15:11.751	2026-07-14 13:02:13.046	cmrknusyu038x4hle19cwnvgc	HIGH_COPY
cmrknuz3x05dn4hle0lgc5kr5	cmrknut0y039h4hlekczcvqvm	\N	SELL	5800000	2026-07-08 10:15:11.751	2026-07-14 13:02:13.053	cmrknusyu038x4hle19cwnvgc	COPY
cmrknuz4305dr4hlebdruirp0	cmrknut0y039h4hlekczcvqvm	\N	SELL	3850000	2026-07-13 08:32:13.052	2026-07-14 13:02:13.059	cmrknusfc03354hletvcgbdfn	ORIGINAL
cmrknuz4905dv4hledxi53qxh	cmrknut0y039h4hlekczcvqvm	\N	SELL	2700000	2026-07-13 08:32:13.052	2026-07-14 13:02:13.065	cmrknusfc03354hletvcgbdfn	HIGH_COPY
cmrknuz4e05dz4hle3a7ivnv1	cmrknut0y039h4hlekczcvqvm	\N	SELL	1500000	2026-07-13 08:32:13.052	2026-07-14 13:02:13.07	cmrknusfc03354hletvcgbdfn	COPY
cmrknuz4k05e34hleehjjrguj	cmrkbbzjk000amneoowf62wmn	\N	SELL	4450000	2026-07-13 14:06:37.73	2026-07-14 13:02:13.076	cmrknusz1038z4hleimlmm6jz	ORIGINAL
cmrknuz4p05e74hlea661cp3v	cmrkbbzjk000amneoowf62wmn	\N	SELL	3450000	2026-07-13 14:06:37.73	2026-07-14 13:02:13.082	cmrknusz1038z4hleimlmm6jz	HIGH_COPY
cmrknuz4u05eb4hlexpzh3hi9	cmrkbbzjk000amneoowf62wmn	\N	SELL	2100000	2026-07-13 14:06:37.73	2026-07-14 13:02:13.086	cmrknusz1038z4hleimlmm6jz	COPY
cmrknuz4z05ef4hledbki1nnw	cmrknut0y039h4hlekczcvqvm	\N	SELL	15900000	2026-07-13 14:07:10.513	2026-07-14 13:02:13.091	cmrknuoj801n54hle7clnsp84	ORIGINAL
cmrknuz5505ej4hleukiyb2ea	cmrknut0y039h4hlekczcvqvm	\N	SELL	12500000	2026-07-13 14:07:10.513	2026-07-14 13:02:13.097	cmrknuoj801n54hle7clnsp84	HIGH_COPY
cmrknuz5b05en4hlee2lhyaz7	cmrknut0y039h4hlekczcvqvm	\N	SELL	7850000	2026-07-13 14:07:10.513	2026-07-14 13:02:13.103	cmrknuoj801n54hle7clnsp84	COPY
cmrknuz5g05er4hle5kh09jwn	cmrknut0y039h4hlekczcvqvm	\N	SELL	43950000	2026-07-13 14:07:48.278	2026-07-14 13:02:13.109	cmrknukiu009t4hlerhv6y22m	ORIGINAL
cmrknuz5n05ev4hleyf9nz36r	cmrknut0y039h4hlekczcvqvm	\N	SELL	39600000	2026-07-13 14:07:48.278	2026-07-14 13:02:13.115	cmrknukiu009t4hlerhv6y22m	HIGH_COPY
cmrknuz5s05ez4hleq7ah6d7t	cmrknut0y039h4hlekczcvqvm	\N	SELL	33500000	2026-07-13 14:07:48.278	2026-07-14 13:02:13.12	cmrknukiu009t4hlerhv6y22m	COPY
cmrknuz5y05f34hlev64a73iw	cmrknut0y039h4hlekczcvqvm	\N	SELL	5900000	2026-07-13 14:09:41.871	2026-07-14 13:02:13.126	cmrknusma03554hle4uw4c3e2	ORIGINAL
cmrknuz6305f74hlelzlj0fka	cmrknut0y039h4hlekczcvqvm	\N	SELL	4400000	2026-07-13 14:09:41.871	2026-07-14 13:02:13.131	cmrknusma03554hle4uw4c3e2	HIGH_COPY
cmrknuz6805fb4hlefiwv1axe	cmrknut0y039h4hlekczcvqvm	\N	SELL	3500000	2026-07-13 14:09:41.871	2026-07-14 13:02:13.136	cmrknusma03554hle4uw4c3e2	COPY
cmrknuz6d05ff4hle55553t2y	cmrknut0y039h4hlekczcvqvm	\N	SELL	4600000	2026-07-13 14:10:48.782	2026-07-14 13:02:13.141	cmrknukcv00674hlej43clu7l	ORIGINAL
cmrknuz6i05fj4hle2ew3nqqe	cmrknut0y039h4hlekczcvqvm	\N	SELL	3300000	2026-07-13 14:10:48.782	2026-07-14 13:02:13.146	cmrknukcv00674hlej43clu7l	HIGH_COPY
cmrknuz6n05fn4hleyvnbuqnz	cmrknut0y039h4hlekczcvqvm	\N	SELL	2200000	2026-07-13 14:10:48.782	2026-07-14 13:02:13.151	cmrknukcv00674hlej43clu7l	COPY
cmrknuz6s05fr4hletgu7ctxw	cmrknut0y039h4hlekczcvqvm	\N	SELL	3800000	2026-07-13 14:12:12.091	2026-07-14 13:02:13.156	cmrknus7n030r4hle8r82udog	ORIGINAL
cmrknuz6x05fv4hlevd168zcm	cmrknut0y039h4hlekczcvqvm	\N	SELL	2500000	2026-07-13 14:12:12.091	2026-07-14 13:02:13.161	cmrknus7n030r4hle8r82udog	HIGH_COPY
cmrknuz7205fz4hlecd223lnf	cmrknut0y039h4hlekczcvqvm	\N	SELL	1800000	2026-07-13 14:12:12.091	2026-07-14 13:02:13.166	cmrknus7n030r4hle8r82udog	COPY
cmrknuz7705g34hlelh6q5341	cmrknut0y039h4hlekczcvqvm	\N	SELL	3950000	2026-07-13 14:12:55.622	2026-07-14 13:02:13.171	cmrknuome01ph4hlepy6pns1m	ORIGINAL
cmrknuz7c05g74hle278pkc8d	cmrknut0y039h4hlekczcvqvm	\N	SELL	2800000	2026-07-13 14:12:55.622	2026-07-14 13:02:13.176	cmrknuome01ph4hlepy6pns1m	HIGH_COPY
cmrknuz7h05gb4hle6u10tndj	cmrknut0y039h4hlekczcvqvm	\N	SELL	1900000	2026-07-13 14:12:55.622	2026-07-14 13:02:13.182	cmrknuome01ph4hlepy6pns1m	COPY
cmrknuz7m05gf4hleo1ghej2w	cmrknut1e039j4hleuqvcm4l6	\N	SELL	14950000	2026-07-13 14:32:51.183	2026-07-14 13:02:13.187	cmrknurk502tv4hledarwecyu	ORIGINAL
cmrknuz7s05gj4hle7bai2iv7	cmrknut1e039j4hleuqvcm4l6	\N	SELL	13800000	2026-07-13 14:32:51.183	2026-07-14 13:02:13.192	cmrknurk502tv4hledarwecyu	HIGH_COPY
cmrknuz7x05gn4hle2ow5sfvr	cmrknut1e039j4hleuqvcm4l6	\N	SELL	12000000	2026-07-13 14:32:51.183	2026-07-14 13:02:13.198	cmrknurk502tv4hledarwecyu	COPY
cmrknuz8205gr4hledu1jcj1u	cmrknut0y039h4hlekczcvqvm	\N	SELL	11950000	2026-07-13 14:33:41.832	2026-07-14 13:02:13.203	cmrknuots01v54hleihbam0j8	ORIGINAL
cmrknuz8705gv4hleu1osid4y	cmrknut0y039h4hlekczcvqvm	\N	SELL	9200000	2026-07-13 14:33:41.832	2026-07-14 13:02:13.207	cmrknuots01v54hleihbam0j8	HIGH_COPY
cmrknuz8d05gz4hle1ep7v70s	cmrknut0y039h4hlekczcvqvm	\N	SELL	3400000	2026-07-13 14:33:41.832	2026-07-14 13:02:13.213	cmrknuots01v54hleihbam0j8	COPY
cmrknuz8h05h34hle8jbosnnr	cmrknut0y039h4hlekczcvqvm	\N	SELL	5600000	2026-07-13 14:34:43.077	2026-07-14 13:02:13.218	cmrknuocd01i14hleqd0rgtvs	ORIGINAL
cmrknuz8m05h74hlekpo70keh	cmrknut0y039h4hlekczcvqvm	\N	SELL	4400000	2026-07-13 14:34:43.077	2026-07-14 13:02:13.222	cmrknuocd01i14hleqd0rgtvs	HIGH_COPY
cmrknuz8s05hb4hledn2cfw8x	cmrknut0y039h4hlekczcvqvm	\N	SELL	3000000	2026-07-13 14:34:43.077	2026-07-14 13:02:13.228	cmrknuocd01i14hleqd0rgtvs	COPY
cmrknuz8x05hf4hlea03eeq6g	cmrknut0y039h4hlekczcvqvm	\N	SELL	3800000	2026-07-13 14:36:18.801	2026-07-14 13:02:13.233	cmrknuozg01zt4hlebqo5ndfn	ORIGINAL
cmrknuz9205hj4hlejoxb5ib2	cmrknut0y039h4hlekczcvqvm	\N	SELL	2500000	2026-07-13 14:36:18.801	2026-07-14 13:02:13.238	cmrknuozg01zt4hlebqo5ndfn	HIGH_COPY
cmrknuz9905hn4hlesm9bdlmh	cmrknut0y039h4hlekczcvqvm	\N	SELL	1400000	2026-07-13 14:36:18.801	2026-07-14 13:02:13.245	cmrknuozg01zt4hlebqo5ndfn	COPY
cmrknuz9h05hr4hlea7j26led	cmrknut0y039h4hlekczcvqvm	\N	SELL	5900000	2026-07-13 14:37:07.985	2026-07-14 13:02:13.254	cmrknukdp006h4hlew8pgxujy	ORIGINAL
cmrknuz9r05hv4hlemb7e5q89	cmrknut0y039h4hlekczcvqvm	\N	SELL	4550000	2026-07-13 14:37:07.985	2026-07-14 13:02:13.263	cmrknukdp006h4hlew8pgxujy	HIGH_COPY
cmrknuza205hz4hleemcqs2sx	cmrknut0y039h4hlekczcvqvm	\N	SELL	3700000	2026-07-13 14:37:07.985	2026-07-14 13:02:13.275	cmrknukdp006h4hlew8pgxujy	COPY
cmrknuzaf05i34hle912r2ebp	cmrkbbzjk000amneoowf62wmn	\N	SELL	2750000	2026-07-13 14:38:15.946	2026-07-14 13:02:13.287	cmrknur2902nl4hlemy5ezwrb	ORIGINAL
cmrknuzar05i74hle4ahglptm	cmrkbbzjk000amneoowf62wmn	\N	SELL	1800000	2026-07-13 14:38:15.946	2026-07-14 13:02:13.299	cmrknur2902nl4hlemy5ezwrb	HIGH_COPY
cmrknuzb305ib4hlefkhclfgz	cmrkbbzjk000amneoowf62wmn	\N	SELL	1200000	2026-07-13 14:38:15.946	2026-07-14 13:02:13.311	cmrknur2902nl4hlemy5ezwrb	COPY
cmrknuzbd05if4hleboid7dm6	cmrknut0y039h4hlekczcvqvm	\N	SELL	12800000	2026-07-13 14:43:33.473	2026-07-14 13:02:13.322	cmrknuszr03974hle47hqgd17	ORIGINAL
cmrknuzbp05ij4hlezsauohps	cmrknut0y039h4hlekczcvqvm	\N	SELL	10900000	2026-07-13 14:43:33.473	2026-07-14 13:02:13.333	cmrknuszr03974hle47hqgd17	HIGH_COPY
cmrknuzbz05in4hlep3xod6nh	cmrknut0y039h4hlekczcvqvm	\N	SELL	9500000	2026-07-13 14:43:33.473	2026-07-14 13:02:13.344	cmrknuszr03974hle47hqgd17	COPY
cmrknuzca05ir4hlerlt04n2l	cmrknut0y039h4hlekczcvqvm	\N	SELL	4700000	2026-07-13 14:44:47.278	2026-07-14 13:02:13.354	cmrknuszf03934hlekzcrisbt	ORIGINAL
cmrknuzcl05iv4hle6m6qj6va	cmrknut0y039h4hlekczcvqvm	\N	SELL	3600000	2026-07-13 14:44:47.278	2026-07-14 13:02:13.365	cmrknuszf03934hlekzcrisbt	HIGH_COPY
cmrknuzcw05iz4hlez8q83lkr	cmrknut0y039h4hlekczcvqvm	\N	SELL	2500000	2026-07-13 14:44:47.278	2026-07-14 13:02:13.376	cmrknuszf03934hlekzcrisbt	COPY
cmrknuzd605j34hleppf2mk2g	cmrknut0y039h4hlekczcvqvm	\N	SELL	6900000	2026-07-13 14:46:12.705	2026-07-14 13:02:13.386	cmrknusz803914hle29zofxbs	ORIGINAL
cmrknuzdi05j74hleos56fwee	cmrknut0y039h4hlekczcvqvm	\N	SELL	5450000	2026-07-13 14:46:12.705	2026-07-14 13:02:13.398	cmrknusz803914hle29zofxbs	HIGH_COPY
cmrknuzdt05jb4hlexrrnm8pj	cmrknut0y039h4hlekczcvqvm	\N	SELL	4100000	2026-07-13 14:46:12.705	2026-07-14 13:02:13.409	cmrknusz803914hle29zofxbs	COPY
cmrknuze405jf4hlet0mlg1n0	cmrknut0y039h4hlekczcvqvm	\N	SELL	9500000	2026-07-13 14:48:33.284	2026-07-14 13:02:13.42	cmrknuoen01j34hlefdj8ynuv	ORIGINAL
cmrknuzeg05jj4hle4r5cnc3l	cmrknut0y039h4hlekczcvqvm	\N	SELL	7800000	2026-07-13 14:48:33.284	2026-07-14 13:02:13.432	cmrknuoen01j34hlefdj8ynuv	HIGH_COPY
cmrknuzes05jn4hleobs82kff	cmrknut0y039h4hlekczcvqvm	\N	SELL	5400000	2026-07-13 14:48:33.284	2026-07-14 13:02:13.444	cmrknuoen01j34hlefdj8ynuv	COPY
cmrknuzf505jr4hle6vhlncoq	cmrknut0y039h4hlekczcvqvm	\N	SELL	13300000	2026-07-13 14:50:01.692	2026-07-14 13:02:13.457	cmrknuoip01mp4hle4i7rw5fr	ORIGINAL
cmrknuzfh05jv4hle8tu0fwmc	cmrknut0y039h4hlekczcvqvm	\N	SELL	10800000	2026-07-13 14:50:01.692	2026-07-14 13:02:13.47	cmrknuoip01mp4hle4i7rw5fr	HIGH_COPY
cmrknuzfu05jz4hle938jazy4	cmrkbbzjk000amneoowf62wmn	\N	SELL	2850000	2026-07-13 14:51:18.784	2026-07-14 13:02:13.482	cmrknuozg01zt4hlebqo5ndfn	ORIGINAL
cmrknuzg705k34hleq7vxeah2	cmrkbbzjk000amneoowf62wmn	\N	SELL	1900000	2026-07-13 14:51:18.784	2026-07-14 13:02:13.495	cmrknuozg01zt4hlebqo5ndfn	HIGH_COPY
cmrknuzgk05k74hlex27b9q95	cmrkbbzjk000amneoowf62wmn	\N	SELL	1300000	2026-07-13 14:51:18.784	2026-07-14 13:02:13.508	cmrknuozg01zt4hlebqo5ndfn	COPY
cmrknuzgz05kb4hleqs1v7kwg	cmrkbbzjk000amneoowf62wmn	\N	SELL	2600000	2026-07-13 14:54:29.773	2026-07-14 13:02:13.523	cmrknunfk017h4hleirfcsgke	ORIGINAL
cmrknuzhd05kf4hleng3vg2a2	cmrkbbzjk000amneoowf62wmn	\N	SELL	1500000	2026-07-13 14:54:29.773	2026-07-14 13:02:13.537	cmrknunfk017h4hleirfcsgke	HIGH_COPY
cmrknuzhp05kj4hle7a1vftg8	cmrkbbzjk000amneoowf62wmn	\N	SELL	800000	2026-07-13 14:54:29.773	2026-07-14 13:02:13.549	cmrknunfk017h4hleirfcsgke	COPY
cmrknuzi305kn4hlew32vzi5r	cmrknut0y039h4hlekczcvqvm	\N	SELL	10900000	2026-07-13 14:58:15.043	2026-07-14 13:02:13.563	cmrknuoq401sd4hleamdfg2qi	ORIGINAL
cmrknuzie05kr4hletrm6n275	cmrknut0y039h4hlekczcvqvm	\N	SELL	7200000	2026-07-13 14:58:15.043	2026-07-14 13:02:13.574	cmrknuoq401sd4hleamdfg2qi	HIGH_COPY
cmrknuziq05kv4hlerbk6av32	cmrknut0y039h4hlekczcvqvm	\N	SELL	5800000	2026-07-13 14:58:15.043	2026-07-14 13:02:13.586	cmrknuoq401sd4hleamdfg2qi	COPY
cmrknuzj205kz4hlejsrw299a	cmrknut0y039h4hlekczcvqvm	\N	SELL	10900000	2026-07-13 15:00:50.913	2026-07-14 13:02:13.598	cmrknukhb008f4hle5zvkb0x6	ORIGINAL
cmrknuzje05l34hlexk7cnn5s	cmrknut0y039h4hlekczcvqvm	\N	SELL	7450000	2026-07-13 15:00:50.913	2026-07-14 13:02:13.61	cmrknukhb008f4hle5zvkb0x6	HIGH_COPY
cmrknuzjq05l74hletvzvb848	cmrknut0y039h4hlekczcvqvm	\N	SELL	4800000	2026-07-13 15:00:50.913	2026-07-14 13:02:13.622	cmrknukhb008f4hle5zvkb0x6	COPY
cmrknuzk305lb4hlegmdc6095	cmrknut0y039h4hlekczcvqvm	\N	SELL	10950000	2026-07-13 15:02:14.482	2026-07-14 13:02:13.635	cmrknuo0z01dd4hleg0f6nasn	ORIGINAL
cmrknuzkf05lf4hle86equ8yj	cmrknut0y039h4hlekczcvqvm	\N	SELL	6900000	2026-07-13 15:02:14.482	2026-07-14 13:02:13.647	cmrknuo0z01dd4hleg0f6nasn	HIGH_COPY
cmrknuzkr05lj4hlelddouqyv	cmrknut0y039h4hlekczcvqvm	\N	SELL	4200000	2026-07-13 15:02:14.482	2026-07-14 13:02:13.659	cmrknuo0z01dd4hleg0f6nasn	COPY
cmrknuzl405ln4hlexb7ji30z	cmrkbbzjk000amneoowf62wmn	\N	SELL	4900000	2026-07-13 15:04:54.916	2026-07-14 13:02:13.672	cmrknuspy03694hleoblpugdm	ORIGINAL
cmrknuzlg05lr4hle58lmdsne	cmrkbbzjk000amneoowf62wmn	\N	SELL	3500000	2026-07-13 15:04:54.916	2026-07-14 13:02:13.684	cmrknuspy03694hleoblpugdm	HIGH_COPY
cmrknuzlq05lv4hlenioos4fi	cmrkbbzjk000amneoowf62wmn	\N	SELL	2900000	2026-07-13 15:04:54.916	2026-07-14 13:02:13.695	cmrknuspy03694hleoblpugdm	COPY
cmrknuzm205lz4hle3wcz8jr3	cmrknut0y039h4hlekczcvqvm	\N	SELL	15600000	2026-07-13 15:07:36.749	2026-07-14 13:02:13.706	cmrknusxk038j4hle6jj6osi9	ORIGINAL
cmrknuzmc05m34hlexrbcersv	cmrknut0y039h4hlekczcvqvm	\N	SELL	12300000	2026-07-13 15:07:36.749	2026-07-14 13:02:13.717	cmrknusxk038j4hle6jj6osi9	HIGH_COPY
cmrknuzmm05m74hle70hec7pz	cmrknut0y039h4hlekczcvqvm	\N	SELL	3500000	2026-07-13 15:07:36.749	2026-07-14 13:02:13.727	cmrknusxk038j4hle6jj6osi9	COPY
cmrknuzmx05mb4hleqys36gze	cmrknut0y039h4hlekczcvqvm	\N	SELL	3700000	2026-07-13 15:10:03.358	2026-07-14 13:02:13.738	cmrknut0a039d4hles56d0cdt	ORIGINAL
cmrknuzn905mf4hle6ye4kx9s	cmrknut0y039h4hlekczcvqvm	\N	SELL	2850000	2026-07-13 15:10:03.358	2026-07-14 13:02:13.749	cmrknut0a039d4hles56d0cdt	HIGH_COPY
cmrknuznk05mj4hle3vafy9ml	cmrknut0y039h4hlekczcvqvm	\N	SELL	1900000	2026-07-13 15:10:03.358	2026-07-14 13:02:13.76	cmrknut0a039d4hles56d0cdt	COPY
cmrknuznu05mn4hle7dsvf11k	cmrknut0y039h4hlekczcvqvm	\N	SELL	12200000	2026-07-13 15:11:45.807	2026-07-14 13:02:13.771	cmrknusga033f4hlelpb105q2	ORIGINAL
cmrknuzo605mr4hle636dlzml	cmrknut0y039h4hlekczcvqvm	\N	SELL	9350000	2026-07-13 15:11:45.807	2026-07-14 13:02:13.782	cmrknusga033f4hlelpb105q2	HIGH_COPY
cmrknuzog05mv4hlev08pb03j	cmrknut0y039h4hlekczcvqvm	\N	SELL	4400000	2026-07-13 15:11:45.807	2026-07-14 13:02:13.792	cmrknusga033f4hlelpb105q2	COPY
cmrknuzor05mz4hleze75c19m	cmrknut0y039h4hlekczcvqvm	\N	SELL	12300000	2026-07-13 15:15:16.62	2026-07-14 13:02:13.803	cmrknusqh036f4hleiqygbn34	ORIGINAL
cmrknuzp305n34hlebh46hmif	cmrknut0y039h4hlekczcvqvm	\N	SELL	9550000	2026-07-13 15:15:16.62	2026-07-14 13:02:13.815	cmrknusqh036f4hleiqygbn34	HIGH_COPY
cmrknuzpd05n74hlekvinmxs2	cmrknut0y039h4hlekczcvqvm	\N	SELL	3900000	2026-07-13 15:15:16.62	2026-07-14 13:02:13.825	cmrknusqh036f4hleiqygbn34	COPY
cmrknuzpo05nb4hlelrfcwwsv	cmrkbbzjk000amneoowf62wmn	\N	SELL	5500000	2026-07-13 15:17:03.73	2026-07-14 13:02:13.836	cmrknut0g039f4hle677spnqb	ORIGINAL
cmrknuzpz05nf4hlecjpbw9cy	cmrkbbzjk000amneoowf62wmn	\N	SELL	4200000	2026-07-13 15:17:03.73	2026-07-14 13:02:13.848	cmrknut0g039f4hle677spnqb	HIGH_COPY
cmrknuzqa05nj4hleh1ywhzea	cmrkbbzjk000amneoowf62wmn	\N	SELL	3500000	2026-07-13 15:17:03.73	2026-07-14 13:02:13.858	cmrknut0g039f4hle677spnqb	COPY
cmrknuzql05nn4hlesq2cdrvx	cmrknut0y039h4hlekczcvqvm	\N	SELL	10950000	2026-07-14 04:43:18.723	2026-07-14 13:02:13.869	cmrknuoh801ld4hlebivzzopl	ORIGINAL
cmrknuzqv05nr4hle3418774a	cmrknut0y039h4hlekczcvqvm	\N	SELL	8400000	2026-07-14 04:43:18.723	2026-07-14 13:02:13.879	cmrknuoh801ld4hlebivzzopl	HIGH_COPY
cmrknuzr505nv4hlem3w15h4k	cmrknut0y039h4hlekczcvqvm	\N	SELL	3500000	2026-07-14 04:43:18.723	2026-07-14 13:02:13.89	cmrknuoh801ld4hlebivzzopl	COPY
\.


--
-- Data for Name: purchases; Type: TABLE DATA; Schema: public; Owner: bartar_user
--

COPY public.purchases (id, "partRequestId", "vendorId", price, description, "buyerId", "purchasedAt", "isReturned", "returnedAt", "returnReason", "createdAt", "updatedAt") FROM stdin;
cmrkbu7rs000nv0qqufs79xrn	cmrkbsj5r0002v0qq19kkmynj	cmrkbu7ra000jv0qqk4pc55f8	48000000	\N	cmrizjjwb0019gmio8se0jmba	2026-07-14 07:25:42.233	t	2026-07-14 07:27:26.109	ایراد داشت	2026-07-14 07:25:42.233	2026-07-14 07:27:26.111
cmrkbyfiy001sv0qqjiresexo	cmrkbxse1001av0qq2iwql35v	cmrkbu7ra000jv0qqk4pc55f8	9000000	\N	cmrizjjwb0019gmio8se0jmba	2026-07-14 07:28:58.906	f	\N	\N	2026-07-14 07:28:58.906	2026-07-14 07:28:58.906
cmrkcslyv0033v0qqqqoej985	cmrkcr0bd002mv0qq0rvkqnhz	cmrkcslyh002zv0qqwb1ku8xp	6000000	\N	cmrizjjwb0019gmio8se0jmba	2026-07-14 07:52:26.935	t	2026-07-14 07:52:47.743	hjf	2026-07-14 07:52:26.935	2026-07-14 07:52:47.744
\.


--
-- Data for Name: repair_tickets; Type: TABLE DATA; Schema: public; Owner: bartar_user
--

COPY public.repair_tickets (id, "ticketNumber", "customerId", "deviceId", status, "createdById", "createdAt", "updatedAt", "deletedAt", "issueDescription") FROM stdin;
cmrkbazce0007mneornfl6o64	1001	cmrkbazbs0000mneo22n4wdvz	cmrkbazc80005mneop7ubdxxn	OPEN	cmrizjjwb0019gmio8se0jmba	2026-07-14 07:10:44.847	2026-07-14 07:10:44.847	\N	\N
\.


--
-- Data for Name: role_permissions; Type: TABLE DATA; Schema: public; Owner: bartar_user
--

COPY public.role_permissions ("roleId", "permissionId", "assignedAt") FROM stdin;
cmrizjinq0012gmio2ui4b52p	cmrizjij60000gmioorc6ppzy	2026-07-13 08:53:41.574
cmrizjinq0012gmio2ui4b52p	cmrizjijl0001gmiofdrcjubm	2026-07-13 08:53:41.591
cmrizjinq0012gmio2ui4b52p	cmrizjijp0002gmiofzf7yzlb	2026-07-13 08:53:41.602
cmrizjinq0012gmio2ui4b52p	cmrizjiju0003gmiok6ik9pay	2026-07-13 08:53:41.614
cmrizjinq0012gmio2ui4b52p	cmrizjijy0004gmioyue6oem9	2026-07-13 08:53:41.625
cmrizjinq0012gmio2ui4b52p	cmrizjik30005gmiomd3k5vbg	2026-07-13 08:53:41.636
cmrizjinq0012gmio2ui4b52p	cmrizjik70006gmiolzjtjrbl	2026-07-13 08:53:41.648
cmrizjinq0012gmio2ui4b52p	cmrizjikc0007gmiotrvwdodn	2026-07-13 08:53:41.659
cmrizjinq0012gmio2ui4b52p	cmrizjikh0008gmio9ozoaft7	2026-07-13 08:53:41.669
cmrizjinq0012gmio2ui4b52p	cmrizjikm0009gmiomo7askru	2026-07-13 08:53:41.681
cmrizjinq0012gmio2ui4b52p	cmrizjikq000agmio6y996gng	2026-07-13 08:53:41.693
cmrizjinq0012gmio2ui4b52p	cmrizjiku000bgmiox59z9bi4	2026-07-13 08:53:41.703
cmrizjinq0012gmio2ui4b52p	cmrizjiky000cgmiozippv960	2026-07-13 08:53:41.713
cmrizjinq0012gmio2ui4b52p	cmrizjil2000dgmio5593xn2k	2026-07-13 08:53:41.724
cmrizjinq0012gmio2ui4b52p	cmrizjil6000egmioey1sdao2	2026-07-13 08:53:41.734
cmrizjinq0012gmio2ui4b52p	cmrizjila000fgmiovim2uaau	2026-07-13 08:53:41.744
cmrizjinq0012gmio2ui4b52p	cmrizjile000ggmio0tqqwbvp	2026-07-13 08:53:41.754
cmrizjinq0012gmio2ui4b52p	cmrizjili000hgmionkimunjh	2026-07-13 08:53:41.764
cmrizjinq0012gmio2ui4b52p	cmrizjilm000igmiobbvrnu3w	2026-07-13 08:53:41.774
cmrizjinq0012gmio2ui4b52p	cmrizjilq000jgmio88sox90h	2026-07-13 08:53:41.784
cmrizjinq0012gmio2ui4b52p	cmrizjilu000kgmiois383r0m	2026-07-13 08:53:41.795
cmrizjinq0012gmio2ui4b52p	cmrizjily000lgmioo9a3uent	2026-07-13 08:53:41.805
cmrizjinq0012gmio2ui4b52p	cmrizjim2000mgmioxpa350kk	2026-07-13 08:53:41.815
cmrizjinq0012gmio2ui4b52p	cmrizjim6000ngmiojjh6ce7r	2026-07-13 08:53:41.825
cmrizjinq0012gmio2ui4b52p	cmrizjima000ogmioouekzad6	2026-07-13 08:53:41.835
cmrizjinq0012gmio2ui4b52p	cmrizjime000pgmio6cyqiers	2026-07-13 08:53:41.845
cmrizjinq0012gmio2ui4b52p	cmrizjimh000qgmiosjb2a4ut	2026-07-13 08:53:41.856
cmrizjinq0012gmio2ui4b52p	cmrizjimk000rgmiok8mtmbn6	2026-07-13 08:53:41.866
cmrizjinq0012gmio2ui4b52p	cmrizjimo000sgmioxn2ggl6p	2026-07-13 08:53:41.877
cmrizjinq0012gmio2ui4b52p	cmrizjimr000tgmioqmiw5154	2026-07-13 08:53:41.888
cmrizjinq0012gmio2ui4b52p	cmrizjimv000ugmionkc44xnp	2026-07-13 08:53:41.899
cmrizjinq0012gmio2ui4b52p	cmrizjimz000vgmiopi5t5pbl	2026-07-13 08:53:41.91
cmrizjinq0012gmio2ui4b52p	cmrizjin2000wgmioai7plt6a	2026-07-13 08:53:41.92
cmrizjinq0012gmio2ui4b52p	cmrizjin6000xgmiobvdee0wp	2026-07-13 08:53:41.931
cmrizjinq0012gmio2ui4b52p	cmrizjina000ygmio9324mxln	2026-07-13 08:53:41.942
cmrizjinq0012gmio2ui4b52p	cmrizjind000zgmiompk5keax	2026-07-13 08:53:41.952
cmrizjinq0012gmio2ui4b52p	cmrizjinh0010gmio0c9uzwor	2026-07-13 08:53:41.964
cmrizjinq0012gmio2ui4b52p	cmrizjinl0011gmioc3gqwqda	2026-07-13 08:53:41.974
cmrizjizi0013gmioa8srhnia	cmrizjim6000ngmiojjh6ce7r	2026-07-13 08:53:41.989
cmrizjizi0013gmioa8srhnia	cmrizjima000ogmioouekzad6	2026-07-13 08:53:42
cmrizjizi0013gmioa8srhnia	cmrizjime000pgmio6cyqiers	2026-07-13 08:53:42.011
cmrizjizi0013gmioa8srhnia	cmrizjimh000qgmiosjb2a4ut	2026-07-13 08:53:42.021
cmrizjizi0013gmioa8srhnia	cmrizjimk000rgmiok8mtmbn6	2026-07-13 08:53:42.031
cmrizjizi0013gmioa8srhnia	cmrizjimo000sgmioxn2ggl6p	2026-07-13 08:53:42.042
cmrizjizi0013gmioa8srhnia	cmrizjimv000ugmionkc44xnp	2026-07-13 08:53:42.052
cmrizjizi0013gmioa8srhnia	cmrizjilq000jgmio88sox90h	2026-07-13 08:53:42.064
cmrizjizi0013gmioa8srhnia	cmrizjilu000kgmiois383r0m	2026-07-13 08:53:42.074
cmrizjizi0013gmioa8srhnia	cmrizjily000lgmioo9a3uent	2026-07-13 08:53:42.083
cmrizjizi0013gmioa8srhnia	cmrizjim2000mgmioxpa350kk	2026-07-13 08:53:42.092
cmrizjizi0013gmioa8srhnia	cmrizjile000ggmio0tqqwbvp	2026-07-13 08:53:42.102
cmrizjizi0013gmioa8srhnia	cmrizjili000hgmionkimunjh	2026-07-13 08:53:42.112
cmrizjizi0013gmioa8srhnia	cmrizjilm000igmiobbvrnu3w	2026-07-13 08:53:42.122
cmrizjizi0013gmioa8srhnia	cmrizjina000ygmio9324mxln	2026-07-13 08:53:42.131
cmrizjizi0013gmioa8srhnia	cmrizjind000zgmiompk5keax	2026-07-13 08:53:42.14
cmrizjizi0013gmioa8srhnia	cmrizjinh0010gmio0c9uzwor	2026-07-13 08:53:42.149
cmrizjizi0013gmioa8srhnia	cmrizjinl0011gmioc3gqwqda	2026-07-13 08:53:42.158
cmrizjizi0013gmioa8srhnia	cmrizjin2000wgmioai7plt6a	2026-07-13 08:53:42.167
cmrizjj4t0014gmiou2mfq2lq	cmrizjijp0002gmiofzf7yzlb	2026-07-13 08:53:42.179
cmrizjj4t0014gmiou2mfq2lq	cmrizjiju0003gmiok6ik9pay	2026-07-13 08:53:42.188
cmrizjj4t0014gmiou2mfq2lq	cmrizjijy0004gmioyue6oem9	2026-07-13 08:53:42.197
cmrizjj4t0014gmiou2mfq2lq	cmrizjik70006gmiolzjtjrbl	2026-07-13 08:53:42.207
cmrizjj4t0014gmiou2mfq2lq	cmrizjikc0007gmiotrvwdodn	2026-07-13 08:53:42.216
cmrizjj4t0014gmiou2mfq2lq	cmrizjikm0009gmiomo7askru	2026-07-13 08:53:42.226
cmrizjj4t0014gmiou2mfq2lq	cmrizjikq000agmio6y996gng	2026-07-13 08:53:42.235
cmrizjj4t0014gmiou2mfq2lq	cmrizjile000ggmio0tqqwbvp	2026-07-13 08:53:42.244
cmrizjj6z0015gmio7aahjhph	cmrizjik70006gmiolzjtjrbl	2026-07-13 08:53:42.257
cmrizjj6z0015gmio7aahjhph	cmrizjikc0007gmiotrvwdodn	2026-07-13 08:53:42.266
cmrizjj6z0015gmio7aahjhph	cmrizjikm0009gmiomo7askru	2026-07-13 08:53:42.276
cmrizjj6z0015gmio7aahjhph	cmrizjikq000agmio6y996gng	2026-07-13 08:53:42.285
cmrizjj840016gmio73nyvk8i	cmrizjikm0009gmiomo7askru	2026-07-13 08:53:42.299
cmrizjj840016gmio73nyvk8i	cmrizjiku000bgmiox59z9bi4	2026-07-13 08:53:42.309
cmrizjj840016gmio73nyvk8i	cmrizjiky000cgmiozippv960	2026-07-13 08:53:42.32
cmrizjj840016gmio73nyvk8i	cmrizjil2000dgmio5593xn2k	2026-07-13 08:53:42.33
cmrizjj840016gmio73nyvk8i	cmrizjil6000egmioey1sdao2	2026-07-13 08:53:42.341
cmrizjj840016gmio73nyvk8i	cmrizjila000fgmiovim2uaau	2026-07-13 08:53:42.352
cmrizjj840016gmio73nyvk8i	cmrizjilq000jgmio88sox90h	2026-07-13 08:53:42.362
cmrizjj840016gmio73nyvk8i	cmrizjim2000mgmioxpa350kk	2026-07-13 08:53:42.372
cmrizjj840016gmio73nyvk8i	cmrizjile000ggmio0tqqwbvp	2026-07-13 08:53:42.382
cmrizjj840016gmio73nyvk8i	cmrizjili000hgmionkimunjh	2026-07-13 08:53:42.393
cmrizjjb40017gmioqjt8s7j0	cmrizjile000ggmio0tqqwbvp	2026-07-13 08:53:42.408
cmrizjjb40017gmioqjt8s7j0	cmrizjili000hgmionkimunjh	2026-07-13 08:53:42.418
cmrizjjb40017gmioqjt8s7j0	cmrizjilm000igmiobbvrnu3w	2026-07-13 08:53:42.428
cmrizjjc30018gmionfafx66m	cmrizjijy0004gmioyue6oem9	2026-07-13 08:53:42.442
cmrizjjc30018gmionfafx66m	cmrizjikm0009gmiomo7askru	2026-07-13 08:53:42.452
cmrizjjc30018gmionfafx66m	cmrizjim2000mgmioxpa350kk	2026-07-13 08:53:42.462
cmrizjjc30018gmionfafx66m	cmrizjile000ggmio0tqqwbvp	2026-07-13 08:53:42.473
cmrizjjc30018gmionfafx66m	cmrizjina000ygmio9324mxln	2026-07-13 08:53:42.482
\.


--
-- Data for Name: roles; Type: TABLE DATA; Schema: public; Owner: bartar_user
--

COPY public.roles (id, name, description, "createdAt", "updatedAt", "deletedAt") FROM stdin;
cmrizjinq0012gmio2ui4b52p	Super Admin	دسترسی کامل به تمام سیستم	2026-07-13 08:53:41.558	2026-07-13 11:29:59.011	\N
cmrizjizi0013gmioa8srhnia	Admin	مدیریت کاربران، قطعات، فروشندگان، قیمت‌ها و تنظیمات	2026-07-13 08:53:41.982	2026-07-13 11:29:59.388	\N
cmrizjj4t0014gmiou2mfq2lq	Reception	ثبت پذیرش، ثبت درخواست قطعه، تایید مشتری، بیعانه	2026-07-13 08:53:42.173	2026-07-13 11:29:59.574	\N
cmrizjj6z0015gmio7aahjhph	Technician	ثبت درخواست قطعه، تست، مصرف، مرجوعی	2026-07-13 08:53:42.251	2026-07-13 11:29:59.652	\N
cmrizjj840016gmio73nyvk8i	Buyer	صف خرید، ثبت خرید، ثبت فروشنده، ثبت قیمت	2026-07-13 08:53:42.293	2026-07-13 11:29:59.692	\N
cmrizjjb40017gmioqjt8s7j0	Pricing Operator	مدیریت قیمت قطعات و تاریخچه قیمت	2026-07-13 08:53:42.4	2026-07-13 11:29:59.792	\N
cmrizjjc30018gmionfafx66m	Viewer	فقط مشاهده	2026-07-13 08:53:42.435	2026-07-13 11:29:59.824	\N
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: public; Owner: bartar_user
--

COPY public.sessions (id, "userId", "tokenHash", "userAgent", ip, "expiresAt", "createdAt") FROM stdin;
cmrj5k7d70001bvevc8i31oor	cmrizjjwb0019gmio8se0jmba	c9f312844bb40e7495549b26290714ab9073a661ef049e18a31ddfd7cf4b865d	curl/8.5.0	::1	2026-08-12 11:42:11.274	2026-07-13 11:42:11.275
cmrj5mdxd0008bvev6cwoaiz8	cmrizjjwb0019gmio8se0jmba	8f4f301ff8881ffa5a1290591c0863671aa7659d06cdbad47daa49403fd88301	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-08-12 11:43:53.088	2026-07-13 11:43:53.089
cmrjhp1ts0004z07555ukpa1c	cmrjho2jn0000z0759oo3jog3	2437afa964aa626558787da8aea39a49a3dce9917f591381c1848b4ba51be0b1	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-08-12 17:21:52.767	2026-07-13 17:21:52.768
cmrjmmvv00001kx820y6c01nr	cmrizjjwb0019gmio8se0jmba	8dc4a357971defedff4c33fed3fb0a4eb8ee02b6e51e869a124982fdcf605a68	Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-08-12 19:40:09.8	2026-07-13 19:40:09.802
cmrkr38fq0001x2ylgmr7yuai	cmrizjjwb0019gmio8se0jmba	b2d8d02c2399d5867b88f1fa924b2b68dcd981f6216ab6fb07ee748de861cf87	Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:152.0) Gecko/20100101 Firefox/152.0	::ffff:127.0.0.1	2026-08-13 14:32:37.236	2026-07-14 14:32:37.239
\.


--
-- Data for Name: status_histories; Type: TABLE DATA; Schema: public; Owner: bartar_user
--

COPY public.status_histories (id, "partRequestId", "previousStatus", "newStatus", "changedById", description, "createdAt") FROM stdin;
cmrjt28gc0004jgwx8uoykqnz	cmrjt28fl0002jgwxknfyfhwt	CREATED	CREATED	cmrizjjwb0019gmio8se0jmba	ثبت درخواست	2026-07-13 22:40:03.658
cmrjt2vf00008jgwx6vlbqq5e	cmrjt28fl0002jgwxknfyfhwt	CREATED	WAITING_CUSTOMER	cmrizjjwb0019gmio8se0jmba	اعلام هزینه	2026-07-13 22:40:33.42
cmrjt35ly000cjgwxntk88kzl	cmrjt28fl0002jgwxknfyfhwt	WAITING_CUSTOMER	APPROVED	cmrizjjwb0019gmio8se0jmba	تایید مشتری	2026-07-13 22:40:46.628
cmrjt35mf000ejgwx5ya1qbme	cmrjt28fl0002jgwxknfyfhwt	APPROVED	WAITING_PURCHASE	cmrizjjwb0019gmio8se0jmba	ورود خودکار به صف خرید	2026-07-13 22:40:46.646
cmrjt3bj1000ijgwxy5tphca1	cmrjt28fl0002jgwxknfyfhwt	WAITING_PURCHASE	PURCHASING	cmrizjjwb0019gmio8se0jmba	شروع خرید	2026-07-13 22:40:54.3
cmrkbbzl3000emneoxuijj4ju	cmrkbbzk9000cmneoxa5m6wyp	CREATED	CREATED	cmrizjjwb0019gmio8se0jmba	ثبت درخواست	2026-07-14 07:11:31.813
cmrkbbzlk000gmneosximc1kh	cmrkbbzk9000cmneoxa5m6wyp	CREATED	WAITING_CUSTOMER	cmrizjjwb0019gmio8se0jmba	اعلام هزینه هنگام ثبت	2026-07-14 07:11:31.83
cmrkbc6gd000kmneo96jm588g	cmrkbbzk9000cmneoxa5m6wyp	WAITING_CUSTOMER	APPROVED	cmrizjjwb0019gmio8se0jmba	تایید مشتری	2026-07-14 07:11:40.717
cmrkbc6gh000mmneo6a0wnz9n	cmrkbbzk9000cmneoxa5m6wyp	APPROVED	WAITING_PURCHASE	cmrizjjwb0019gmio8se0jmba	ورود خودکار به صف خرید	2026-07-14 07:11:40.722
cmrkbc9nx000qmneo1b1te3i0	cmrkbbzk9000cmneoxa5m6wyp	WAITING_PURCHASE	PURCHASING	cmrizjjwb0019gmio8se0jmba	شروع خرید	2026-07-14 07:11:44.877
cmrkbsj6k0004v0qqjgnoo3ls	cmrkbsj5r0002v0qq19kkmynj	CREATED	CREATED	cmrizjjwb0019gmio8se0jmba	ثبت درخواست	2026-07-14 07:24:23.707
cmrkbsj710006v0qqbsu4pme7	cmrkbsj5r0002v0qq19kkmynj	CREATED	WAITING_CUSTOMER	cmrizjjwb0019gmio8se0jmba	اعلام هزینه هنگام ثبت	2026-07-14 07:24:23.723
cmrkbsqwl000av0qq3jv4ss2b	cmrkbsj5r0002v0qq19kkmynj	WAITING_CUSTOMER	APPROVED	cmrizjjwb0019gmio8se0jmba	تایید مشتری	2026-07-14 07:24:33.717
cmrkbsqwq000cv0qq739t2y5j	cmrkbsj5r0002v0qq19kkmynj	APPROVED	WAITING_PURCHASE	cmrizjjwb0019gmio8se0jmba	ورود خودکار به صف خرید	2026-07-14 07:24:33.722
cmrkbstsn000gv0qqx1zhujqs	cmrkbsj5r0002v0qq19kkmynj	WAITING_PURCHASE	PURCHASING	cmrizjjwb0019gmio8se0jmba	شروع خرید	2026-07-14 07:24:37.463
cmrkbu7ur000pv0qqi3dfico4	cmrkbsj5r0002v0qq19kkmynj	PURCHASING	PURCHASED	cmrizjjwb0019gmio8se0jmba	خرید از موبایل ستاک — ۴۸٬۰۰۰٬۰۰۰ تومان	2026-07-14 07:25:42.338
cmrkbwfxq0011v0qqsteoc7ky	cmrkbsj5r0002v0qq19kkmynj	PURCHASED	RETURNED	cmrizjjwb0019gmio8se0jmba	مرجوعی: ایراد داشت	2026-07-14 07:27:26.126
cmrkbxsea001cv0qq2f8pj2l4	cmrkbxse1001av0qq2iwql35v	CREATED	CREATED	cmrizjjwb0019gmio8se0jmba	ثبت درخواست	2026-07-14 07:28:28.929
cmrkbxseg001ev0qqropb7wbg	cmrkbxse1001av0qq2iwql35v	CREATED	WAITING_CUSTOMER	cmrizjjwb0019gmio8se0jmba	اعلام هزینه هنگام ثبت	2026-07-14 07:28:28.937
cmrkbxx92001iv0qqxxomcxmc	cmrkbxse1001av0qq2iwql35v	WAITING_CUSTOMER	APPROVED	cmrizjjwb0019gmio8se0jmba	تایید مشتری	2026-07-14 07:28:35.222
cmrkbxx95001kv0qqdzdea4hp	cmrkbxse1001av0qq2iwql35v	APPROVED	WAITING_PURCHASE	cmrizjjwb0019gmio8se0jmba	ورود خودکار به صف خرید	2026-07-14 07:28:35.225
cmrkby2nz001ov0qquuddi553	cmrkbxse1001av0qq2iwql35v	WAITING_PURCHASE	PURCHASING	cmrizjjwb0019gmio8se0jmba	شروع خرید	2026-07-14 07:28:42.239
cmrkbyfk2001uv0qq6nyl217b	cmrkbxse1001av0qq2iwql35v	PURCHASING	PURCHASED	cmrizjjwb0019gmio8se0jmba	خرید از موبایل ستاک — ۹٬۰۰۰٬۰۰۰ تومان	2026-07-14 07:28:58.944
cmrkcpimv0029v0qqql5zcwzd	cmrkcpilv0027v0qqsgolo27p	CREATED	CREATED	cmrizjjwb0019gmio8se0jmba	ثبت درخواست	2026-07-14 07:50:02.646
cmrkcpin8002bv0qqlfsx9hou	cmrkcpilv0027v0qqsgolo27p	CREATED	WAITING_CUSTOMER	cmrizjjwb0019gmio8se0jmba	اعلام هزینه هنگام ثبت	2026-07-14 07:50:02.659
cmrkcps2w002fv0qq50bysula	cmrkcpilv0027v0qqsgolo27p	WAITING_CUSTOMER	APPROVED	cmrizjjwb0019gmio8se0jmba	تایید مشتری	2026-07-14 07:50:14.888
cmrkcps2z002hv0qqi0ubnq1v	cmrkcpilv0027v0qqsgolo27p	APPROVED	WAITING_PURCHASE	cmrizjjwb0019gmio8se0jmba	ورود خودکار به صف خرید	2026-07-14 07:50:14.891
cmrkcr0c5002ov0qqdo9vddq2	cmrkcr0bd002mv0qq0rvkqnhz	CREATED	CREATED	cmrizjjwb0019gmio8se0jmba	ثبت درخواست	2026-07-14 07:51:12.244
cmrkcr0cl002qv0qq2j0bjjho	cmrkcr0bd002mv0qq0rvkqnhz	CREATED	WAITING_CUSTOMER	cmrizjjwb0019gmio8se0jmba	اعلام هزینه هنگام ثبت	2026-07-14 07:51:12.259
cmrkcr6gc002uv0qq9z5fjdom	cmrkcr0bd002mv0qq0rvkqnhz	WAITING_CUSTOMER	APPROVED	cmrizjjwb0019gmio8se0jmba	تایید مشتری	2026-07-14 07:51:20.17
cmrkcr6gq002wv0qq5giqf99t	cmrkcr0bd002mv0qq0rvkqnhz	APPROVED	WAITING_PURCHASE	cmrizjjwb0019gmio8se0jmba	ورود خودکار به صف خرید	2026-07-14 07:51:20.185
cmrkcslzs0035v0qqpj4ms74n	cmrkcr0bd002mv0qq0rvkqnhz	WAITING_PURCHASE	PURCHASING	cmrizjjwb0019gmio8se0jmba	شروع خرید (هنگام ثبت خرید)	2026-07-14 07:52:26.967
cmrkcsm020037v0qqvfs2j7sc	cmrkcr0bd002mv0qq0rvkqnhz	PURCHASING	PURCHASED	cmrizjjwb0019gmio8se0jmba	خرید از jhdhd — ۶٬۰۰۰٬۰۰۰ تومان	2026-07-14 07:52:26.977
cmrkct21f003jv0qqc9hwltbv	cmrkcr0bd002mv0qq0rvkqnhz	PURCHASED	RETURNED	cmrizjjwb0019gmio8se0jmba	مرجوعی: hjf	2026-07-14 07:52:47.763
\.


--
-- Data for Name: user_roles; Type: TABLE DATA; Schema: public; Owner: bartar_user
--

COPY public.user_roles ("userId", "roleId", "assignedAt") FROM stdin;
cmrizjjwb0019gmio8se0jmba	cmrizjinq0012gmio2ui4b52p	2026-07-13 08:53:43.168
cmrjgnmzd0000imy3xvld7io7	cmrizjj6z0015gmio7aahjhph	2026-07-13 16:52:47.257
cmrjho2jn0000z0759oo3jog3	cmrizjj4t0014gmiou2mfq2lq	2026-07-13 17:21:07.044
cmrjho2jn0000z0759oo3jog3	cmrizjj840016gmio73nyvk8i	2026-07-13 17:21:07.044
cmrjho2jn0000z0759oo3jog3	cmrizjjb40017gmioqjt8s7j0	2026-07-13 17:21:07.044
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: bartar_user
--

COPY public.users (id, name, phone, email, "passwordHash", "isActive", "createdAt", "updatedAt", "deletedAt") FROM stdin;
cmrizjjwb0019gmio8se0jmba	مدیر سیستم	09120000000	\N	$2a$12$.bofI.V6f3/N6r/5z5xOnehX5OnpdncrqCpRFLWN2dm7CSxiSo5K6	t	2026-07-13 08:53:43.163	2026-07-13 08:53:43.163	\N
cmrjgnmzd0000imy3xvld7io7	علی تعمیرکار	09121111111	\N	$2a$12$ViWMdZXdBwSYl4Cgdf1JkOd2FogKJQteIhGV7rdbV3QUP6rnsLPSK	t	2026-07-13 16:52:47.257	2026-07-13 16:52:47.257	\N
cmrjho2jn0000z0759oo3jog3	مهدی رحیمی	09916352600	\N	$2a$12$E.orm52OZK6V1.P4l/uJeuwb1R8u5q2yoV/DBsDL2cDCh8RoIZdvO	t	2026-07-13 17:21:07.044	2026-07-13 17:21:07.044	\N
\.


--
-- Data for Name: vendors; Type: TABLE DATA; Schema: public; Owner: bartar_user
--

COPY public.vendors (id, name, phone, address, "isActive", "createdAt", "updatedAt", "deletedAt") FROM stdin;
cmrkbu7ra000jv0qqk4pc55f8	موبایل ستاک	\N	\N	t	2026-07-14 07:25:42.215	2026-07-14 07:25:42.215	\N
cmrkcslyh002zv0qqwb1ku8xp	jhdhd	\N	\N	t	2026-07-14 07:52:26.921	2026-07-14 07:52:26.921	\N
\.


--
-- Name: _prisma_migrations _prisma_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: bartar_user
--

ALTER TABLE ONLY public._prisma_migrations
    ADD CONSTRAINT _prisma_migrations_pkey PRIMARY KEY (id);


--
-- Name: activity_logs activity_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: bartar_user
--

ALTER TABLE ONLY public.activity_logs
    ADD CONSTRAINT activity_logs_pkey PRIMARY KEY (id);


--
-- Name: attachments attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: bartar_user
--

ALTER TABLE ONLY public.attachments
    ADD CONSTRAINT attachments_pkey PRIMARY KEY (id);


--
-- Name: brands brands_pkey; Type: CONSTRAINT; Schema: public; Owner: bartar_user
--

ALTER TABLE ONLY public.brands
    ADD CONSTRAINT brands_pkey PRIMARY KEY (id);


--
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: public; Owner: bartar_user
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (id);


--
-- Name: device_models device_models_pkey; Type: CONSTRAINT; Schema: public; Owner: bartar_user
--

ALTER TABLE ONLY public.device_models
    ADD CONSTRAINT device_models_pkey PRIMARY KEY (id);


--
-- Name: device_types device_types_pkey; Type: CONSTRAINT; Schema: public; Owner: bartar_user
--

ALTER TABLE ONLY public.device_types
    ADD CONSTRAINT device_types_pkey PRIMARY KEY (id);


--
-- Name: devices devices_pkey; Type: CONSTRAINT; Schema: public; Owner: bartar_user
--

ALTER TABLE ONLY public.devices
    ADD CONSTRAINT devices_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: bartar_user
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: part_prices part_prices_pkey; Type: CONSTRAINT; Schema: public; Owner: bartar_user
--

ALTER TABLE ONLY public.part_prices
    ADD CONSTRAINT part_prices_pkey PRIMARY KEY (id);


--
-- Name: part_requests part_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: bartar_user
--

ALTER TABLE ONLY public.part_requests
    ADD CONSTRAINT part_requests_pkey PRIMARY KEY (id);


--
-- Name: parts parts_pkey; Type: CONSTRAINT; Schema: public; Owner: bartar_user
--

ALTER TABLE ONLY public.parts
    ADD CONSTRAINT parts_pkey PRIMARY KEY (id);


--
-- Name: permissions permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: bartar_user
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (id);


--
-- Name: price_histories price_histories_pkey; Type: CONSTRAINT; Schema: public; Owner: bartar_user
--

ALTER TABLE ONLY public.price_histories
    ADD CONSTRAINT price_histories_pkey PRIMARY KEY (id);


--
-- Name: purchases purchases_pkey; Type: CONSTRAINT; Schema: public; Owner: bartar_user
--

ALTER TABLE ONLY public.purchases
    ADD CONSTRAINT purchases_pkey PRIMARY KEY (id);


--
-- Name: repair_tickets repair_tickets_pkey; Type: CONSTRAINT; Schema: public; Owner: bartar_user
--

ALTER TABLE ONLY public.repair_tickets
    ADD CONSTRAINT repair_tickets_pkey PRIMARY KEY (id);


--
-- Name: role_permissions role_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: bartar_user
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_pkey PRIMARY KEY ("roleId", "permissionId");


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: bartar_user
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: bartar_user
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: status_histories status_histories_pkey; Type: CONSTRAINT; Schema: public; Owner: bartar_user
--

ALTER TABLE ONLY public.status_histories
    ADD CONSTRAINT status_histories_pkey PRIMARY KEY (id);


--
-- Name: user_roles user_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: bartar_user
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_pkey PRIMARY KEY ("userId", "roleId");


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: bartar_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: vendors vendors_pkey; Type: CONSTRAINT; Schema: public; Owner: bartar_user
--

ALTER TABLE ONLY public.vendors
    ADD CONSTRAINT vendors_pkey PRIMARY KEY (id);


--
-- Name: activity_logs_entityType_entityId_idx; Type: INDEX; Schema: public; Owner: bartar_user
--

CREATE INDEX "activity_logs_entityType_entityId_idx" ON public.activity_logs USING btree ("entityType", "entityId");


--
-- Name: brands_name_key; Type: INDEX; Schema: public; Owner: bartar_user
--

CREATE UNIQUE INDEX brands_name_key ON public.brands USING btree (name);


--
-- Name: device_models_brandId_name_key; Type: INDEX; Schema: public; Owner: bartar_user
--

CREATE UNIQUE INDEX "device_models_brandId_name_key" ON public.device_models USING btree ("brandId", name);


--
-- Name: device_types_name_key; Type: INDEX; Schema: public; Owner: bartar_user
--

CREATE UNIQUE INDEX device_types_name_key ON public.device_types USING btree (name);


--
-- Name: part_prices_modelId_partId_quality_key; Type: INDEX; Schema: public; Owner: bartar_user
--

CREATE UNIQUE INDEX "part_prices_modelId_partId_quality_key" ON public.part_prices USING btree ("modelId", "partId", quality);


--
-- Name: parts_name_key; Type: INDEX; Schema: public; Owner: bartar_user
--

CREATE UNIQUE INDEX parts_name_key ON public.parts USING btree (name);


--
-- Name: permissions_code_key; Type: INDEX; Schema: public; Owner: bartar_user
--

CREATE UNIQUE INDEX permissions_code_key ON public.permissions USING btree (code);


--
-- Name: repair_tickets_ticketNumber_key; Type: INDEX; Schema: public; Owner: bartar_user
--

CREATE UNIQUE INDEX "repair_tickets_ticketNumber_key" ON public.repair_tickets USING btree ("ticketNumber");


--
-- Name: roles_name_key; Type: INDEX; Schema: public; Owner: bartar_user
--

CREATE UNIQUE INDEX roles_name_key ON public.roles USING btree (name);


--
-- Name: sessions_tokenHash_key; Type: INDEX; Schema: public; Owner: bartar_user
--

CREATE UNIQUE INDEX "sessions_tokenHash_key" ON public.sessions USING btree ("tokenHash");


--
-- Name: sessions_userId_idx; Type: INDEX; Schema: public; Owner: bartar_user
--

CREATE INDEX "sessions_userId_idx" ON public.sessions USING btree ("userId");


--
-- Name: users_email_key; Type: INDEX; Schema: public; Owner: bartar_user
--

CREATE UNIQUE INDEX users_email_key ON public.users USING btree (email);


--
-- Name: users_phone_key; Type: INDEX; Schema: public; Owner: bartar_user
--

CREATE UNIQUE INDEX users_phone_key ON public.users USING btree (phone);


--
-- Name: activity_logs activity_logs_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bartar_user
--

ALTER TABLE ONLY public.activity_logs
    ADD CONSTRAINT "activity_logs_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: attachments attachments_partRequestId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bartar_user
--

ALTER TABLE ONLY public.attachments
    ADD CONSTRAINT "attachments_partRequestId_fkey" FOREIGN KEY ("partRequestId") REFERENCES public.part_requests(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: device_models device_models_brandId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bartar_user
--

ALTER TABLE ONLY public.device_models
    ADD CONSTRAINT "device_models_brandId_fkey" FOREIGN KEY ("brandId") REFERENCES public.brands(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: device_models device_models_deviceTypeId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bartar_user
--

ALTER TABLE ONLY public.device_models
    ADD CONSTRAINT "device_models_deviceTypeId_fkey" FOREIGN KEY ("deviceTypeId") REFERENCES public.device_types(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: devices devices_brandId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bartar_user
--

ALTER TABLE ONLY public.devices
    ADD CONSTRAINT "devices_brandId_fkey" FOREIGN KEY ("brandId") REFERENCES public.brands(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: devices devices_modelId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bartar_user
--

ALTER TABLE ONLY public.devices
    ADD CONSTRAINT "devices_modelId_fkey" FOREIGN KEY ("modelId") REFERENCES public.device_models(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: notifications notifications_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bartar_user
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT "notifications_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: part_prices part_prices_modelId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bartar_user
--

ALTER TABLE ONLY public.part_prices
    ADD CONSTRAINT "part_prices_modelId_fkey" FOREIGN KEY ("modelId") REFERENCES public.device_models(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: part_prices part_prices_partId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bartar_user
--

ALTER TABLE ONLY public.part_prices
    ADD CONSTRAINT "part_prices_partId_fkey" FOREIGN KEY ("partId") REFERENCES public.parts(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: part_requests part_requests_createdById_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bartar_user
--

ALTER TABLE ONLY public.part_requests
    ADD CONSTRAINT "part_requests_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: part_requests part_requests_modelId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bartar_user
--

ALTER TABLE ONLY public.part_requests
    ADD CONSTRAINT "part_requests_modelId_fkey" FOREIGN KEY ("modelId") REFERENCES public.device_models(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: part_requests part_requests_partId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bartar_user
--

ALTER TABLE ONLY public.part_requests
    ADD CONSTRAINT "part_requests_partId_fkey" FOREIGN KEY ("partId") REFERENCES public.parts(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: part_requests part_requests_repairTicketId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bartar_user
--

ALTER TABLE ONLY public.part_requests
    ADD CONSTRAINT "part_requests_repairTicketId_fkey" FOREIGN KEY ("repairTicketId") REFERENCES public.repair_tickets(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: price_histories price_histories_modelId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bartar_user
--

ALTER TABLE ONLY public.price_histories
    ADD CONSTRAINT "price_histories_modelId_fkey" FOREIGN KEY ("modelId") REFERENCES public.device_models(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: price_histories price_histories_partId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bartar_user
--

ALTER TABLE ONLY public.price_histories
    ADD CONSTRAINT "price_histories_partId_fkey" FOREIGN KEY ("partId") REFERENCES public.parts(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: price_histories price_histories_purchaseId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bartar_user
--

ALTER TABLE ONLY public.price_histories
    ADD CONSTRAINT "price_histories_purchaseId_fkey" FOREIGN KEY ("purchaseId") REFERENCES public.purchases(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: purchases purchases_buyerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bartar_user
--

ALTER TABLE ONLY public.purchases
    ADD CONSTRAINT "purchases_buyerId_fkey" FOREIGN KEY ("buyerId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: purchases purchases_partRequestId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bartar_user
--

ALTER TABLE ONLY public.purchases
    ADD CONSTRAINT "purchases_partRequestId_fkey" FOREIGN KEY ("partRequestId") REFERENCES public.part_requests(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: purchases purchases_vendorId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bartar_user
--

ALTER TABLE ONLY public.purchases
    ADD CONSTRAINT "purchases_vendorId_fkey" FOREIGN KEY ("vendorId") REFERENCES public.vendors(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: repair_tickets repair_tickets_createdById_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bartar_user
--

ALTER TABLE ONLY public.repair_tickets
    ADD CONSTRAINT "repair_tickets_createdById_fkey" FOREIGN KEY ("createdById") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: repair_tickets repair_tickets_customerId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bartar_user
--

ALTER TABLE ONLY public.repair_tickets
    ADD CONSTRAINT "repair_tickets_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES public.customers(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: repair_tickets repair_tickets_deviceId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bartar_user
--

ALTER TABLE ONLY public.repair_tickets
    ADD CONSTRAINT "repair_tickets_deviceId_fkey" FOREIGN KEY ("deviceId") REFERENCES public.devices(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: role_permissions role_permissions_permissionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bartar_user
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT "role_permissions_permissionId_fkey" FOREIGN KEY ("permissionId") REFERENCES public.permissions(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: role_permissions role_permissions_roleId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bartar_user
--

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT "role_permissions_roleId_fkey" FOREIGN KEY ("roleId") REFERENCES public.roles(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: sessions sessions_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bartar_user
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT "sessions_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: status_histories status_histories_changedById_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bartar_user
--

ALTER TABLE ONLY public.status_histories
    ADD CONSTRAINT "status_histories_changedById_fkey" FOREIGN KEY ("changedById") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: status_histories status_histories_partRequestId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bartar_user
--

ALTER TABLE ONLY public.status_histories
    ADD CONSTRAINT "status_histories_partRequestId_fkey" FOREIGN KEY ("partRequestId") REFERENCES public.part_requests(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: user_roles user_roles_roleId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bartar_user
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT "user_roles_roleId_fkey" FOREIGN KEY ("roleId") REFERENCES public.roles(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: user_roles user_roles_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: bartar_user
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT "user_roles_userId_fkey" FOREIGN KEY ("userId") REFERENCES public.users(id) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- PostgreSQL database dump complete
--

\unrestrict GKfU85ZpqdAuJaQgj1dQOqAjBnvWWV6YkwYxwna0vvxndJ21nwJdMgBwDVXtNqo

