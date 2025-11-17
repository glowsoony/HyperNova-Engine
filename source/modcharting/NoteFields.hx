package modcharting;

import flixel.group.FlxGroup.FlxTypedGroup;
import modcharting.NoteField;
import modcharting.PlayfieldRenderer.NotefieldData;

class NoteFields extends FlxTypedGroup<NoteField>
{
    public var storedObjects:Array<NotefieldData> = [];
    public var hasStoredObjects:Bool = true;

    public function new(MaxSize:Int = 0)
    {
        super(MaxSize);
        memberAdded.add(function(field:NoteField) {
            var allowAdd:Bool = true;
            for (object in storedObjects)
                if (object.field == field)
                {
                    allowAdd = false;
                    break;
                }
            if (!allowAdd) return;
            storedObjects.add(field);
        });
        memberRemoved.add(function(field:NoteField) {
            var allowRemove:Bool = false;
            for (object in storedObjects)
                if (object.field == field)
                {
                    allowRemove = true;
                    break;
                }
            if (!allowRemove) return;
            storedObjects.remove(field);
        });
    }

    public function findIndex(index:Int):Int
    {
        for (field in storedObjects)
        {
            if (field.index != index) continue;
            return field.memberIndex;
        }
        return -1;
    }

    
	override public function insert(position:Int, object:NoteField):NoteField
	{
		if (object == null)
		{
			FlxG.log.warn("Cannot insert a `null` object into a FlxGroup.");
			return null;
		}

		// Don't bother inserting an object twice.
		if (members.indexOf(object) >= 0)
			return object;

		// First, look if the member at position is null, so we can directly assign the object at the position.
		if (position < length && members[position] == null)
		{
			members[position] = object;
			onMemberAdd(object);
            onMemberAtIndex(object, position);
			
			return object;
		}

		// If the group is full, return the object
		if (maxSize > 0 && length >= maxSize)
			return object;

		// If we made it this far, we need to insert the object into the group at the specified position.
		members.insert(position, object);
		length++;
		onMemberAdd(object);
        onMemberAtIndex(object, position);

		return object;
	}

    public function onMemberAtIndex(object:NoteField, position:Int):NoteField
    {
        final index:Int = findIndexByNoteField(object);
        if (index == -1 || index == position)
            return object;
        storedObjects[index].memberIndex = members.indexOf(object);
        return object;
    }

    public function getByIndex(index:Int):NoteField
    {
        final ogIndex:Int = findIndex(index);
        return members[ogIndex];
    }

    public function findIndexByNoteField(notefield:NoteField):Int
    {
        for (field in storedObjects)
        {
            if (field.field != notefield) continue;
            return field.memberIndex;
        }
        return -1;
    }

    public function getByNotefield(notefield:NoteField):NoteField
    {
        final ogIndex:Int = findIndexByNoteField(notefield);
        return members[ogIndex];
    }
}