--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.4
-- Dumped by pg_dump version 9.5.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: loads; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE loads (
    id integer NOT NULL,
    delivery_date date,
    delivery_shift character varying,
    truck_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    orders_count integer DEFAULT 0 NOT NULL
);


--
-- Name: loads_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE loads_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: loads_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE loads_id_seq OWNED BY loads.id;


--
-- Name: orders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE orders (
    id integer NOT NULL,
    delivery_date date,
    delivery_shift character varying,
    origin_name character varying,
    origin_address character varying,
    origin_city character varying,
    origin_state character varying,
    origin_zip character varying,
    origin_country character varying,
    client_name character varying,
    destination_address character varying,
    destination_city character varying,
    destination_state character varying,
    destination_zip character varying,
    destination_country character varying,
    phone_number character varying,
    mode character varying,
    purchase_order_number character varying,
    volume double precision,
    handling_unit_quantity integer,
    handling_unit_type character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    delivery_order integer NOT NULL,
    load_id integer
);


--
-- Name: order_delivery_order_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE order_delivery_order_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: order_delivery_order_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE order_delivery_order_seq OWNED BY orders.delivery_order;


--
-- Name: orders_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE orders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE orders_id_seq OWNED BY orders.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: trucks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE trucks (
    id integer NOT NULL,
    user_id integer,
    max_weight integer,
    max_volume integer
);


--
-- Name: trucks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE trucks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: trucks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE trucks_id_seq OWNED BY trucks.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE users (
    id integer NOT NULL,
    login character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    remember_created_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    role character varying
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY loads ALTER COLUMN id SET DEFAULT nextval('loads_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY orders ALTER COLUMN id SET DEFAULT nextval('orders_id_seq'::regclass);


--
-- Name: delivery_order; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY orders ALTER COLUMN delivery_order SET DEFAULT nextval('order_delivery_order_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY trucks ALTER COLUMN id SET DEFAULT nextval('trucks_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: loads_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY loads
    ADD CONSTRAINT loads_pkey PRIMARY KEY (id);


--
-- Name: orders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);


--
-- Name: trucks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY trucks
    ADD CONSTRAINT trucks_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_loads_on_delivery_shift_and_delivery_date_and_truck_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_loads_on_delivery_shift_and_delivery_date_and_truck_id ON loads USING btree (delivery_shift, delivery_date, truck_id);


--
-- Name: index_loads_on_truck_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_loads_on_truck_id ON loads USING btree (truck_id);


--
-- Name: index_orders_on_delivery_order_and_load_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_orders_on_delivery_order_and_load_id ON orders USING btree (delivery_order, load_id) WHERE ((load_id IS NOT NULL) AND (delivery_order IS NOT NULL));


--
-- Name: index_orders_on_load_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_orders_on_load_id ON orders USING btree (load_id);


--
-- Name: index_trucks_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_trucks_on_user_id ON trucks USING btree (user_id);


--
-- Name: index_users_on_login; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_login ON users USING btree (login);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: fk_rails_6e2d5dc503; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY orders
    ADD CONSTRAINT fk_rails_6e2d5dc503 FOREIGN KEY (load_id) REFERENCES loads(id);


--
-- Name: fk_rails_86106a6ce5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY loads
    ADD CONSTRAINT fk_rails_86106a6ce5 FOREIGN KEY (truck_id) REFERENCES trucks(id);


--
-- Name: fk_rails_97ffea0962; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY trucks
    ADD CONSTRAINT fk_rails_97ffea0962 FOREIGN KEY (user_id) REFERENCES users(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO schema_migrations (version) VALUES ('20161101174905');

INSERT INTO schema_migrations (version) VALUES ('20161102082753');

INSERT INTO schema_migrations (version) VALUES ('20161102160357');

INSERT INTO schema_migrations (version) VALUES ('20161103213026');

INSERT INTO schema_migrations (version) VALUES ('20161104193302');

INSERT INTO schema_migrations (version) VALUES ('20161104212803');

INSERT INTO schema_migrations (version) VALUES ('20161105191909');

INSERT INTO schema_migrations (version) VALUES ('20161105222951');

INSERT INTO schema_migrations (version) VALUES ('20161106130351');

INSERT INTO schema_migrations (version) VALUES ('20161107085957');

