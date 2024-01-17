package internal

import (
	"fmt"
	"strings"
)

func Order(bucket []string) ([]string, error) {
	schemas := make([]string, 0)
	extensions := make([]string, 0)
	types := make([]string, 0)
	domains := make([]string, 0)
	tables := make([]string, 0)
	triggers := make([]string, 0)
	functions := make([]string, 0)
	rules := make([]string, 0)
	altersDrops := make([]string, 0)
	altersAdd := make([]string, 0)
	altersModify := make([]string, 0)

	for _, item := range bucket {
		value := ReplaceManyWithOne(strings.ToLower(item), ' ', ' ')
		if strings.HasPrefix(value, "create table") {
			tables = append(tables, item)
			continue
		}
		if strings.HasPrefix(value, "create function") || strings.HasPrefix(value, "create or replace function") {
			functions = append(functions, item)
			continue
		}
		if strings.HasPrefix(value, "create trigger") {
			triggers = append(triggers, Guard(item, "duplicate_object"))
			continue
		}
		if strings.HasPrefix(value, "create or replace trigger") {
			triggers = append(triggers, item)
			continue
		}
		if strings.HasPrefix(value, "create rule") {
			rules = append(rules, Guard(item, "duplicate_object"))
			continue
		}
		if strings.HasPrefix(value, "create or replace rule") {
			rules = append(rules, item)
			continue
		}
		if strings.HasPrefix(value, "alter table") {
			if strings.Contains(value, "add column") || strings.Contains(value, "add constraint") {
				altersAdd = append(altersAdd, Guard(item, "duplicate_object"))
				continue
			}
			if strings.Contains(value, "drop column") || strings.Contains(value, "drop constraint") {
				altersDrops = append(altersDrops, item)
				continue
			}
			if strings.Contains(value, "alter column") {
				altersModify = append(altersModify, item)
				continue
			}
		}
		if strings.HasPrefix(value, "create extension") {
			extensions = append(extensions, Guard(item, "duplicate_object"))
			continue
		}
		if strings.HasPrefix(value, "create schema") {
			schemas = append(schemas, Guard(item, "duplicate_schema"))
			continue
		}
		if strings.HasPrefix(value, "create type") {
			types = append(types, Guard(item, "duplicate_object"))
			continue
		}
		if strings.HasPrefix(value, "create domain") {
			domains = append(domains, Guard(item, "duplicate_object"))
			continue
		}
		return nil, fmt.Errorf("unsupported sql: %s", value)
	}
	out := make([]string, 0)
	out = append(out, schemas...)
	out = append(out, extensions...)
	out = append(out, types...)
	out = append(out, domains...)
	out = append(out, tables...)
	out = append(out, altersDrops...)
	out = append(out, altersAdd...)
	out = append(out, altersModify...)
	out = append(out, functions...)
	out = append(out, triggers...)
	out = append(out, rules...)
	return out, nil
}

func ReplaceManyWithOne(str string, old rune, new rune) string {
	split := strings.FieldsFunc(str, func(r rune) bool {
		return r == old
	})
	return strings.Join(split, string(new))
}

func Guard(item string, execption string) string {
	return fmt.Sprintf(
		`DO $$ BEGIN
	%s
EXCEPTION
	WHEN %s THEN null;
END $$;`,
		strings.ReplaceAll(item, "\r\n", "\r\n\t"),
		execption,
	)
}
