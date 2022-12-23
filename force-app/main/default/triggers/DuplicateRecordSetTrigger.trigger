/**
	Duplicate Handling helper code
    Copyright (C) 2021 David Schach

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
*/

/**
 * Trigger for DuplicateRecordItem
 * @author {@link [David Schach](https://github.com/dschach)}
 * @since 04/19/2021     Initial Version
 * @since 02/28/2022     Static to instance trigger handler methods
 **/
trigger DuplicateRecordSetTrigger on DuplicateRecordSet(after update) {
	new DuplicateRecordSetTriggerHandler().handleTrigger(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap, Trigger.operationType);
}